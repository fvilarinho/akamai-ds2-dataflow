package com.akamai.ds2.converter;

import com.akamai.ds2.converter.constants.Constants;
import com.akamai.ds2.converter.constants.ConverterConstants;
import com.akamai.ds2.converter.monitoring.MonitoringAgent;
import com.akamai.ds2.converter.util.ConverterUtil;
import com.akamai.ds2.converter.util.SettingsUtil;
import com.akamai.ds2.converter.util.helpers.Worker;
import org.apache.kafka.clients.admin.*;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class App {
    private static final Logger logger = LogManager.getLogger(Constants.DEFAULT_APP_NAME);

    private static Properties prepareKafkaConsumerParameters() throws IOException{
        String brokers = SettingsUtil.getKafkaBrokers();

        logger.info("Preparing the inbound connection to {}...", brokers);

        Properties properties = new Properties();

        properties.setProperty(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, SettingsUtil.getKafkaBrokers());
        properties.setProperty(ConsumerConfig.GROUP_ID_CONFIG, Constants.DEFAULT_APP_NAME);
        properties.setProperty(ConsumerConfig.CLIENT_ID_CONFIG, ConverterUtil.getId());
        properties.setProperty(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.setProperty(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.setProperty(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        return properties;
    }

    private static Properties prepareKafkaProducerParameters() throws IOException{
        String brokers = SettingsUtil.getKafkaBrokers();

        logger.info("Preparing the outbound connection to {}...", brokers);

        Properties properties = new Properties();

        properties.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, SettingsUtil.getKafkaBrokers());
        properties.setProperty(ProducerConfig.CLIENT_ID_CONFIG, ConverterUtil.getId());
        properties.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        return properties;
    }

    private static Map<String, Object> prepareKafkaAdminParameters() throws IOException {
        Map<String, Object> properties = new HashMap<>();

        properties.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, SettingsUtil.getKafkaBrokers());

        return properties;
    }

    private void loadSettings() throws IOException {
        logger.info("Loading settings...");

        SettingsUtil.load();

        logger.info("Settings loaded!");
    }

    private void createAndUpdateTopics() throws IOException, ExecutionException, InterruptedException {
        AdminClient admin = null;

        try {
            final String inboundTopic = SettingsUtil.getKafkaInboundTopic();
            final String outboundTopic = SettingsUtil.getKafkaOutboundTopic();
            final int partitionNumber = SettingsUtil.getCount();
            final short replicationFactor = SettingsUtil.getReplicationFactor();

            admin = AdminClient.create(prepareKafkaAdminParameters());

            ListTopicsResult result = admin.listTopics();
            Set<String> topicsList = result.names().get();
            List<NewTopic> newTopicsList = null;
            Map<String, NewPartitions> topicsPartitions = null;

            if (topicsList == null || topicsList.isEmpty() || !topicsList.contains(inboundTopic)) {
                newTopicsList = new ArrayList<>();
                newTopicsList.add(new NewTopic(inboundTopic, partitionNumber, replicationFactor));
            }
            else {
                topicsPartitions = new HashMap<>();
                topicsPartitions.put(inboundTopic, NewPartitions.increaseTo(partitionNumber));
            }

            if (topicsList == null || topicsList.isEmpty() || !topicsList.contains(outboundTopic)) {
                if (newTopicsList == null)
                    newTopicsList = new ArrayList<>();

                newTopicsList.add(new NewTopic(outboundTopic, partitionNumber, replicationFactor));
            }
            else {
                if (topicsPartitions == null)
                    topicsPartitions = new HashMap<>();

                topicsPartitions.put(outboundTopic, NewPartitions.increaseTo(partitionNumber));
            }

            if (newTopicsList != null) {
                logger.info("Creating queues...");

                admin.createTopics(newTopicsList);

                logger.info("Queues created!");
            }

            if (topicsPartitions != null) {
                logger.info("Updating queues...");

                admin.createPartitions(topicsPartitions);

                logger.info("Queues updated!");
            }
        }
        finally {
            if (admin != null)
                admin.close();
        }
    }

    private void consumeMessages() throws IOException {
        KafkaConsumer<String, String> inbound = null;
        KafkaProducer<String, String> outbound = null;
        ExecutorService workersManager = null;
        MonitoringAgent monitoringAgent;

        try {
            final String inboundTopic = SettingsUtil.getKafkaInboundTopic();
            final String outboundTopic = SettingsUtil.getKafkaOutboundTopic();

            logger.info("Subscribing to the queue {}...", inboundTopic);

            outbound = new KafkaProducer<>(prepareKafkaProducerParameters());
            inbound = new KafkaConsumer<>(prepareKafkaConsumerParameters());

            inbound.subscribe(Collections.singletonList(inboundTopic));

            workersManager = Executors.newFixedThreadPool(SettingsUtil.getWorkers());
            monitoringAgent = MonitoringAgent.getInstance();

            while (true) {
                try {
                    ConsumerRecords<String, String> inboundMessages = inbound.poll(Duration.ofMillis(100));

                    if (!inboundMessages.isEmpty()) {
                        monitoringAgent.setRawMessagesCount(System.currentTimeMillis(), inboundMessages.count());

                        for (ConsumerRecord<String, String> inboundMessage : inboundMessages)
                            workersManager.submit(new Worker(inboundMessage, outbound, outboundTopic));
                    }
                }
                catch(Throwable e) {
                    break;
                }
            }
        }
        catch(Throwable  e) {
            logger.error(e.getMessage());
        }
        finally {
            if (inbound != null)
                inbound.close();

            if (outbound != null)
                outbound.close();

            if (workersManager != null) {
                logger.info("Stopping all workers...");

                try {
                    workersManager.shutdown();

                    if (workersManager.awaitTermination(ConverterConstants.DEFAULT_WORKERS_TIMEOUT, TimeUnit.SECONDS))
                        logger.info("All workers terminated!");
                    else
                        logger.info("Termination timeout reached!");
                }
                catch (Throwable ignored) {
                }
            }
        }
    }

    public void run(){
        try {
            loadSettings();
            createAndUpdateTopics();
            consumeMessages();
        }
        catch (IOException | ExecutionException | InterruptedException e){
            logger.error(e);
        }
    }

    public static void main(String[] args){
        new App().run();
    }
}
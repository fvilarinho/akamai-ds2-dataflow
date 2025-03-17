package com.akamai.ds2.converter.util.helpers;

import com.akamai.ds2.converter.constants.Constants;
import com.akamai.ds2.converter.monitoring.MonitoringAgent;
import com.akamai.ds2.converter.util.ConverterUtil;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.List;

public class Worker implements Runnable {
    private static final Logger logger = LogManager.getLogger(Constants.DEFAULT_APP_NAME);

    private final KafkaProducer<String, String> outbound;
    private final String outboundTopic;
    private final ConsumerRecord<String, String> inboundMessage;

    public Worker(ConsumerRecord<String, String> inboundMessage, KafkaProducer<String, String> outbound, String outboundTopic) {
        this.inboundMessage = inboundMessage;
        this.outbound = outbound;
        this.outboundTopic = outboundTopic;
    }

    @Override
    public void run() {
        String key = this.inboundMessage.key();
        String value = this.inboundMessage.value();

        try {
            if (value != null && !value.isEmpty()) {
                List<String> messages = ConverterUtil.process(value);

                if (messages != null && !messages.isEmpty()) {
                    MonitoringAgent monitoringAgent = MonitoringAgent.getInstance();

                    int count = 0;

                    for (String message : messages) {
                        if (ConverterUtil.filter(message)) {
                            this.outbound.send(new ProducerRecord<>(this.outboundTopic, key, message));
                            this.outbound.flush();

                            count++;
                        }
                    }

                    if (count > 0) {
                        if (count > 1)
                            logger.info("{} messages processed...", count);
                        else
                            logger.info("{} message processed...", count);

                        monitoringAgent.setProcessedMessagesCount(inboundMessage.timestamp(), count);
                    }
                }
            }
        }
        catch (Throwable e) {
            logger.error(e);
        }
    }
}
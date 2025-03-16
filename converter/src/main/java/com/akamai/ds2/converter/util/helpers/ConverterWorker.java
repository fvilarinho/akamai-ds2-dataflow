package com.akamai.ds2.converter.util.helpers;

import com.akamai.ds2.converter.App;
import com.akamai.ds2.converter.constants.Constants;
import com.akamai.ds2.converter.monitoring.MetricsAgent;
import com.akamai.ds2.converter.util.ConverterUtil;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.List;

public class ConverterWorker implements Runnable {
    private static final Logger logger = LogManager.getLogger(Constants.DEFAULT_APP_NAME);

    private final KafkaProducer<String, String> outbound;
    private final String outboundTopic;
    private final ConsumerRecord<String, String> inboundMessage;

    public ConverterWorker(ConsumerRecord<String, String> inboundMessage, KafkaProducer<String, String> outbound, String outboundTopic) {
        this.inboundMessage = inboundMessage;
        this.outbound = outbound;
        this.outboundTopic = outboundTopic;
    }

    @Override
    public void run() {
        String key = this.inboundMessage.key();
        String value = this.inboundMessage.value();

        if (value != null && !value.isEmpty()) {
            try {
                List<String> messages = ConverterUtil.process(value);
                int count = 0;

                if (messages != null && !messages.isEmpty()) {

                    for (String message : messages) {
                        if(ConverterUtil.filter(message)) {
                            this.outbound.send(new ProducerRecord<>(this.outboundTopic, key, message));

                            this.outbound.flush();

                            count++;
                        }
                    }

                    if(count > 0) {
                        if (count > 1)
                            logger.info("{} messages processed...", count);
                        else
                            logger.info("{} message processed...", count);
                    }
                }

                MetricsAgent.getInstance(App.getId()).updateProcessedMessagesCount(count);
                MetricsAgent.getInstance(App.getId()).updateProcessedMessagesActual(count);
            }
            catch (Throwable e) {
                logger.error(e);
            }
        }
    }
}
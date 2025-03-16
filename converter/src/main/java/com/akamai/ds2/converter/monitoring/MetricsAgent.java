package com.akamai.ds2.converter.monitoring;

import com.akamai.ds2.converter.constants.Constants;
import io.prometheus.client.Counter;
import io.prometheus.client.Gauge;
import io.prometheus.client.exporter.HTTPServer;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;

public class MetricsAgent {
    private static final Logger logger = LogManager.getLogger(Constants.DEFAULT_APP_NAME);

    private static final Counter rawMessagesCount = Counter.build()
                                                    .name("raw_messages_count")
                                                    .help("Total number of messages to be processed.")
                                                    .labelNames("name")
                                                    .register();

    private static final Gauge rawMessagesActual = Gauge.build()
                                                    .name("raw_messages_actual")
                                                    .help("Actual number of  messages to be processed.")
                                                    .labelNames("name")
                                                    .register();

    private static final Counter processedMessagesCount = Counter.build()
                                                          .name("processed_messages_count")
                                                          .help("Total number of messages processed.")
                                                          .labelNames("name")
                                                          .register();

    private static final Gauge processedMessagesActual = Gauge.build()
                                                         .name("processed__messages_actual")
                                                         .help("Actual number of messages processed.")
                                                         .labelNames("name")
                                                         .register();

    private static final Gauge receiptDelay = Gauge.build()
                                              .name("receipt_delay")
                                              .help("Delay (in ms) of the receipt of the message.")
                                              .labelNames("name")
                                              .register();

    private static MetricsAgent instance;

    private final String id;

    private MetricsAgent(String id) throws IOException {
        super();

        this.id = id;

        try(HTTPServer server = new HTTPServer(9001);) {
            logger.info("Initializing metrics agent...");
        }
    }

    public static MetricsAgent getInstance(String id) throws IOException {
        if (instance == null)
            instance = new MetricsAgent(id);

        return instance;
    }

    public void updateRawMessagesCount(Integer count) {
        rawMessagesCount.labels(this.id).inc(count.doubleValue());
    }

    public void updateRawMessagesActual(Integer actual) {
        rawMessagesActual.labels(this.id).set(actual.doubleValue());
    }

    public void updateProcessedMessagesCount(Integer count) {
        processedMessagesCount.labels(this.id).inc(count.doubleValue());
    }

    public void updateProcessedMessagesActual(Integer actual) {
        processedMessagesActual.labels(this.id).set(actual.doubleValue());
    }

    public void updateReceiptDelay(Long delay) {
        receiptDelay.labels(this.id).set(delay.doubleValue());
    }
}
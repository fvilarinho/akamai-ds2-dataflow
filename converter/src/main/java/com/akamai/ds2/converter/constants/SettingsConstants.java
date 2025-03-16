package com.akamai.ds2.converter.constants;

public class SettingsConstants {
    public static final Integer DEFAULT_COUNT = 1;
    public static final String DEFAULT_ETC_DIR = "etc/";
    public static final String DEFAULT_FILENAME = "settings.json";
    public static final String DEFAULT_FILEPATH = DEFAULT_ETC_DIR.concat(DEFAULT_FILENAME);
    public static final String DEFAULT_KAFKA_INBOUND_TOPIC = "rawlogs";
    public static final String DEFAULT_KAFKA_OUTBOUND_TOPIC = "processedlogs";
    public static final String DEFAULT_KAFKA_BROKERS = "kafka-broker:9092";
    public static final Integer DEFAULT_WORKERS = 10;
    public static final String FILEPATH = "${ETC_DIR}/".concat(DEFAULT_FILENAME);

    public static final String COUNT_ATTRIBUTE_ID = "count";
    public static final String FILTERS_ATTRIBUTE_ID = "filters";
    public static final String KAFKA_BROKERS_ATTRIBUTE_ID = "kafka.brokers";
    public static final String KAFKA_INBOUND_TOPIC_ATTRIBUTE_ID = "kafka.inboundTopic";
    public static final String KAFKA_OUTBOUND_TOPIC_ATTRIBUTE_ID = "kafka.outboundTopic";
    public static final String WORKERS_ATTRIBUTE_ID = "workers";
}
package com.akamai.ds2.converter.constants;

public class SettingsConstants {
    public static final String  DEFAULT_ETC_DIR = "etc/";
    public static final String  DEFAULT_FILENAME = "settings.json";
    public static final String  DEFAULT_FILEPATH = DEFAULT_ETC_DIR.concat(DEFAULT_FILENAME);
    public static final String  DEFAULT_KAFKA_AUTH_CONFIG = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"%s\" password=\"%s\";";
    public static final String  DEFAULT_KAFKA_AUTH_MECHANISM = "PLAIN";
    public static final String  DEFAULT_KAFKA_AUTH_PROTOCOL = "SASL_PLAINTEXT";
    public static final String  DEFAULT_KAFKA_INBOUND_TOPIC = "rawlogs";
    public static final String  DEFAULT_KAFKA_OUTBOUND_TOPIC = "processedlogs";
    public static final String  DEFAULT_KAFKA_BROKERS = "kafka-broker:9092";
    public static final Integer DEFAULT_WORKERS = 10;
    public static final String  FILEPATH = "${ETC_DIR}/".concat(DEFAULT_FILENAME);
    public static final String  FILTERS_ATTRIBUTE_ID = "filters";
    public static final String  KAFKA_BROKERS_ATTRIBUTE_ID = "kafka.brokers";
    public static final String  KAFKA_AUTH_PROTOCOL_ATTRIBUTE_ID = "security.protocol";
    public static final String  KAFKA_AUTH_MECHANISM_ATTRIBUTE_ID = "sasl.mechanism";
    public static final String  KAFKA_AUTH_CONFIG_ATTRIBUTE_ID = "sasl.jaas.config";
    public static final String  KAFKA_AUTH_USER_ATTRIBUTE_ID = "kafka.auth.user";
    public static final String  KAFKA_AUTH_PASSWORD_ATTRIBUTE_ID = "kafka.auth.password";
    public static final String  KAFKA_INBOUND_TOPIC_ATTRIBUTE_ID = "kafka.inboundTopic";
    public static final String  KAFKA_OUTBOUND_TOPIC_ATTRIBUTE_ID = "kafka.outboundTopic";
    public static final String  WORKERS_ATTRIBUTE_ID = "workers";
}
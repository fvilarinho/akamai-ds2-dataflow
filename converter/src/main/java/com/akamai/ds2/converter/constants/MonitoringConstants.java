package com.akamai.ds2.converter.constants;

public class MonitoringConstants {
    public static final String DEFAULT_MONITORING_URL = "http://monitoring-database:8086";
    public static final String MONITORING_URL = "http://${MONITORING_HOSTNAME}:${MONITORING_PORT}";

    public static final String COUNT_ATTRIBUTE_ID = "count";
    public static final String DELAY_ATTRIBUTE_ID = "delay";
    public static final String ERROR_ATTRIBUTE_ID = "error";
    public static final String MESSAGE_ATTRIBUTE_ID = "message";
    public static final String PROCESSED_ATTRIBUTE_ID = "processed";
    public static final String RAW_ATTRIBUTE_ID = "raw";
    public static final String RECEIPT_RAW_ATTRIBUTE_ID = "receipt";
    public static final String SOURCE_ATTRIBUTE_ID = "source";
}

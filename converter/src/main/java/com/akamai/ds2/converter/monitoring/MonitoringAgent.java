package com.akamai.ds2.converter.monitoring;

import com.akamai.ds2.converter.constants.MonitoringConstants;
import com.akamai.ds2.converter.util.ConverterUtil;
import org.influxdb.InfluxDB;
import org.influxdb.InfluxDBFactory;
import org.influxdb.dto.Point;
import org.influxdb.dto.Pong;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

public class MonitoringAgent {
    private static MonitoringAgent instance;

    private InfluxDB client;
    private boolean connected;

    private MonitoringAgent() {
        super();

        connect();
    }

    public void connect(){
        if(this.client == null || !this.connected) {
            String hostname = System.getenv(MonitoringConstants.MONITORING_HOSTNAME_ATTRIBUTE_ID);
            int port = Integer.parseInt(System.getenv(MonitoringConstants.MONITORING_PORT_ATTRIBUTE_ID));
            String url = String.format("http://%s:%d", hostname, port);

            this.client = InfluxDBFactory.connect(url);
            this.client.setDatabase(com.akamai.ds2.converter.constants.Constants.DEFAULT_APP_NAME);

            Pong pong = this.client.ping();

            this.connected = (pong != null && pong.isGood());
        }
    }

    public static MonitoringAgent getInstance() {
        if(instance == null)
            instance = new MonitoringAgent();

        instance.connect();

        return instance;
    }

    public void setReceiptDelay(final long timestamp, final long delay) {
        if(this.connected) {
            new Thread(new MonitoringAgentThread(this.client) {
                @Override
                public void run() {
                    try {
                        getClient().write(Point.measurement(MonitoringConstants.MONITORING_RECEIPT_RAW_ATTRIBUTE_ID)
                                   .time(timestamp, TimeUnit.MILLISECONDS)
                                   .addField(MonitoringConstants.MONITORING_DELAY_ATTRIBUTE_ID, delay)
                                   .addField(MonitoringConstants.MONITORING_SOURCE_ATTRIBUTE_ID, ConverterUtil.getId()).build());
                    }
                    catch(IOException ignored) {
                    }
                }
            }).start();
        }
    }

    public void setRawCount(final long timestamp, final long count) {
        if(this.connected) {
            new Thread(new MonitoringAgentThread(this.client) {
                @Override
                public void run() {
                    try {
                        getClient().write(Point.measurement(MonitoringConstants.MONITORING_RAW_ATTRIBUTE_ID)
                                   .time(timestamp, TimeUnit.MILLISECONDS)
                                   .addField(MonitoringConstants.MONITORING_COUNT_ATTRIBUTE_ID, count)
                                   .addField(MonitoringConstants.MONITORING_SOURCE_ATTRIBUTE_ID, ConverterUtil.getId()).build());
                    }
                    catch(IOException ignored) {
                    }
                }
            }).start();
        }
    }

    public void setProcessedCount(final long timestamp, final long count) {
        if(this.connected) {
            new Thread(new MonitoringAgentThread(this.client) {
                @Override
                public void run() {
                    try {
                        getClient().write(Point.measurement(MonitoringConstants.MONITORING_PROCESSED_ATTRIBUTE_ID)
                                   .time(timestamp, TimeUnit.MILLISECONDS)
                                   .addField(MonitoringConstants.MONITORING_COUNT_ATTRIBUTE_ID, count)
                                   .addField(MonitoringConstants.MONITORING_SOURCE_ATTRIBUTE_ID, ConverterUtil.getId()).build());
                    }
                    catch(IOException ignored) {
                    }
                }
            }).start();
        }
    }

    public void disconnect() {
        if (this.client != null) {
            this.client.close();

            this.client = null;
        }

        this.connected = false;
    }
}

abstract class MonitoringAgentThread implements Runnable {
    private InfluxDB client;

    public MonitoringAgentThread(InfluxDB client) {
        super();

        setClient(client);
    }

    protected InfluxDB getClient() {
        return this.client;
    }

    private void setClient(InfluxDB client) {
        this.client = client;
    }
}
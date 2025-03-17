package com.akamai.ds2.converter.monitoring;

import com.akamai.ds2.converter.monitoring.constants.Constants;
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
            String hostname = System.getenv(Constants.MONITORING_HOSTNAME_ATTRIBUTE_ID);
            int port = Integer.parseInt(System.getenv(Constants.MONITORING_PORT_ATTRIBUTE_ID));
            String url = "http://" + hostname + ":" + port;

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

    public void setMessageReceiptDelay(final long timestamp, final long messageTimestamp) {
        if(this.connected) {
            new Thread(new MonitoringAgentThread(this.client) {
                @Override
                public void run() {
                    try {
                        getClient().write(Point.measurement("messageReceiptDelay")
                                .time(timestamp, TimeUnit.MILLISECONDS)
                                .addField("delay", (timestamp - messageTimestamp))
                                .addField("source", ConverterUtil.getId()).build());
                    }
                    catch(IOException ignored) {
                    }
                }
            }).start();
        }
    }

    public void setRawMessagesCount(final long timestamp, final long count) {
        if(this.connected) {
            new Thread(new MonitoringAgentThread(this.client) {
                @Override
                public void run() {
                    try {
                        getClient().write(Point.measurement("rawMessages")
                                   .time(timestamp, TimeUnit.MILLISECONDS)
                                   .addField("count", count)
                                   .addField("source", ConverterUtil.getId()).build());
                    }
                    catch(IOException ignored) {
                    }
                }
            }).start();
        }
    }

    public void setProcessedMessagesCount(final long timestamp, final long count) {
        if(this.connected) {
            new Thread(new MonitoringAgentThread(this.client) {
                @Override
                public void run() {
                    try {
                        getClient().write(Point.measurement("processedMessages")
                                   .time(timestamp, TimeUnit.MILLISECONDS)
                                   .addField("count", count)
                                   .addField("source", ConverterUtil.getId()).build());
                    }
                    catch(IOException ignored) {
                    }
                }
            }).start();
        }
    }

    public void disconnect() {
        this.client.close();

        this.client = null;
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
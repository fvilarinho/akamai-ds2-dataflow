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
        String hostname = System.getenv(Constants.MONITORING_HOSTNAME_ATTRIBUTE_ID);
        int port = Integer.parseInt(System.getenv(Constants.MONITORING_PORT_ATTRIBUTE_ID));

        String url = "http://" + hostname + ":" + port;

        if(this.client == null || !this.connected) {
            this.client = InfluxDBFactory.connect(url);
            this.client.setDatabase("metrics");

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

    public void setRawMessagesCount(long count) {
        if(this.connected) {
            try {
                this.client.write(Point.measurement("rawMessages")
                           .time(System.currentTimeMillis(), TimeUnit.MILLISECONDS)
                           .addField("count", count)
                           .addField("source", ConverterUtil.getId()).build());
            }
            catch(IOException ignored) {
            }
        }
    }

    public void setProcessedMessagesCount(long count) {
        if(this.connected) {
            try {
                this.client.write(Point.measurement("processedMessage")
                           .time(System.currentTimeMillis(), TimeUnit.MILLISECONDS)
                           .addField("count", count)
                           .addField("source", ConverterUtil.getId()).build());
            }
            catch(IOException ignored) {
            }
        }
    }

    public void disconnect() {
        this.client.close();

        this.client = null;
        this.connected = false;
    }
}
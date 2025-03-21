package com.akamai.ds2.converter.monitoring;

import com.akamai.ds2.converter.constants.Constants;
import com.akamai.ds2.converter.constants.MonitoringConstants;
import com.akamai.ds2.converter.util.ConverterUtil;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.influxdb.InfluxDB;
import org.influxdb.InfluxDBFactory;
import org.influxdb.dto.Point;
import org.influxdb.dto.Pong;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MonitoringAgent {
    private static final Logger logger = LogManager.getLogger(Constants.DEFAULT_APP_NAME);

    private static MonitoringAgent instance;

    private InfluxDB client;
    private boolean connected;

    private MonitoringAgent() {
        super();

        connect();
    }

    public void connect(){
        if (this.client == null || !this.connected) {
            Map<String, String> environmentMap = System.getenv();
            Pattern pattern = Pattern.compile("\\$\\{(.*?)?}");
            String monitoringUrl = MonitoringConstants.MONITORING_URL;
            Matcher matcher = pattern.matcher(monitoringUrl);

            while (matcher.find()) {
                String environmentVariableExpression = matcher.group(0);
                String environmentVariableName = matcher.group(1);
                String environmentVariableValue = environmentMap.get(environmentVariableName);

                if (environmentVariableValue == null)
                    environmentVariableValue = StringUtils.EMPTY;

                monitoringUrl = StringUtils.replace(monitoringUrl, environmentVariableExpression, environmentVariableValue);
            }

            if(monitoringUrl.isEmpty())
                monitoringUrl = MonitoringConstants.DEFAULT_MONITORING_URL;

            try {
                this.client = InfluxDBFactory.connect(monitoringUrl);
                this.client.setDatabase(Constants.DEFAULT_APP_NAME);

                Pong pong = this.client.ping();

                this.connected = (pong != null && pong.isGood());
            }
            catch(Throwable e){
                logger.error(e);

                this.connected = false;
                this.client = null;
            }
        }
    }

    public static MonitoringAgent getInstance() {
        if (instance == null)
            instance = new MonitoringAgent();

        instance.connect();

        return instance;
    }

    public void logReceiptDelay(final long timestamp, final long delay) {
        if (this.connected) {
            new Thread(new MonitoringAgentThread(this.client) {
                @Override
                public void run() {
                    try {
                        getClient().write(Point.measurement(MonitoringConstants.RECEIPT_RAW_ATTRIBUTE_ID)
                                   .time(timestamp, TimeUnit.MILLISECONDS)
                                   .addField(MonitoringConstants.DELAY_ATTRIBUTE_ID, delay)
                                   .addField(MonitoringConstants.SOURCE_ATTRIBUTE_ID, ConverterUtil.getId()).build());
                    }
                    catch(IOException ignored) {
                    }
                }
            }).start();
        }
    }

    public void logRawCount(final long timestamp, final long count) {
        if (this.connected) {
            new Thread(new MonitoringAgentThread(this.client) {
                @Override
                public void run() {
                    try {
                        getClient().write(Point.measurement(MonitoringConstants.RAW_ATTRIBUTE_ID)
                                   .time(timestamp, TimeUnit.MILLISECONDS)
                                   .addField(MonitoringConstants.COUNT_ATTRIBUTE_ID, count)
                                   .addField(MonitoringConstants.SOURCE_ATTRIBUTE_ID, ConverterUtil.getId()).build());
                    }
                    catch(IOException ignored) {
                    }
                }
            }).start();
        }
    }
    
    public void logError(final long timestamp, Throwable e) {
        if (this.connected) {
            new Thread(new MonitoringAgentThread(this.client) {
                @Override
                public void run() {
                    try {
                        String message = e.getMessage();

                        if(message == null || message.isEmpty())
                            message = String.format("Unknown error threw by %s", e.getClass().getName());

                        getClient().write(Point.measurement(MonitoringConstants.ERROR_ATTRIBUTE_ID)
                                .time(timestamp, TimeUnit.MILLISECONDS)
                                .addField(MonitoringConstants.MESSAGE_ATTRIBUTE_ID, message)
                                .addField(MonitoringConstants.COUNT_ATTRIBUTE_ID, 1)
                                .addField(MonitoringConstants.SOURCE_ATTRIBUTE_ID, ConverterUtil.getId()).build());
                    }
                    catch(IOException ignored) {
                    }
                }
            }).start();
        }
    }

    public void logProcessedCount(final long timestamp, final long count) {
        if (this.connected) {
            new Thread(new MonitoringAgentThread(this.client) {
                @Override
                public void run() {
                    try {
                        getClient().write(Point.measurement(MonitoringConstants.PROCESSED_ATTRIBUTE_ID)
                                   .time(timestamp, TimeUnit.MILLISECONDS)
                                   .addField(MonitoringConstants.COUNT_ATTRIBUTE_ID, count)
                                   .addField(MonitoringConstants.SOURCE_ATTRIBUTE_ID, ConverterUtil.getId()).build());
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
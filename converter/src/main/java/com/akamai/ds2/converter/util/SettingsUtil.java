package com.akamai.ds2.converter.util;

import com.akamai.ds2.converter.constants.SettingsConstants;
import com.akamai.ds2.converter.util.helpers.Filter;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.StringUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class SettingsUtil {
    private static final ObjectMapper mapper = new ObjectMapper();

    private static Map<String, Object> settings = null;

    public static Map<String, Object> get() throws IOException {
        if (settings == null)
            load();

        return settings;
    }

    public static void load(InputStream in) throws IOException {
        if (in == null)
            throw new IOException("Settings file not found!");

        settings = mapper.readValue(in, new TypeReference<>() {
        });
    }

    public static void load() throws IOException {
        Map<String, String> environmentMap = System.getenv();
        Pattern pattern = Pattern.compile("\\$\\{(.*?)?}");
        String settingsFilepath = SettingsConstants.FILEPATH;
        Matcher matcher = pattern.matcher(settingsFilepath);

        while (matcher.find()) {
            String environmentVariableExpression = matcher.group(0);
            String environmentVariableName = matcher.group(1);
            String environmentVariableValue = environmentMap.get(environmentVariableName);

            if (environmentVariableValue == null)
                environmentVariableValue = StringUtils.EMPTY;

            settingsFilepath = StringUtils.replace(settingsFilepath, environmentVariableExpression, environmentVariableValue);
        }

        File settingsFile = new File(settingsFilepath);

        if (!settingsFile.exists() || !settingsFile.canRead()) {
            InputStream in = SettingsUtil.class.getClassLoader().getResourceAsStream(settingsFilepath);

            if (in == null)
                in = SettingsUtil.class.getClassLoader().getResourceAsStream(SettingsConstants.DEFAULT_FILEPATH);

            load(in);
        }
        else
            load(new FileInputStream(settingsFilepath));
    }

    public static Short getReplicationFactor() throws IOException {
        List<?> brokersList = JsonUtil.getAttribute(get(), SettingsConstants.KAFKA_BROKERS_ATTRIBUTE_ID);

        if (brokersList == null || brokersList.isEmpty())
            return 1;

        return Short.valueOf(String.valueOf(brokersList.size()));
    }

    public static String getKafkaBrokers() throws IOException {
        List<?> brokersList = JsonUtil.getAttribute(get(), SettingsConstants.KAFKA_BROKERS_ATTRIBUTE_ID);

        if (brokersList == null || brokersList.isEmpty())
            return SettingsConstants.DEFAULT_KAFKA_BROKERS;

        StringBuilder brokers = new StringBuilder();

        for (Object broker : brokersList) {
            if (!brokers.isEmpty())
                brokers.append(",");

            brokers.append(broker);
        }

        return brokers.toString();
    }


    public static String getKafkaInboundTopic() throws IOException {
        String inboundTopic = JsonUtil.getAttribute(get(), SettingsConstants.KAFKA_INBOUND_TOPIC_ATTRIBUTE_ID);

        if (inboundTopic == null || inboundTopic.isEmpty())
            inboundTopic = SettingsConstants.DEFAULT_KAFKA_INBOUND_TOPIC;

        return inboundTopic;
    }

    public static String getKafkaOutboundTopic() throws IOException {
        String outboundTopic = JsonUtil.getAttribute(get(), SettingsConstants.KAFKA_OUTBOUND_TOPIC_ATTRIBUTE_ID);

        if (outboundTopic == null || outboundTopic.isEmpty())
            outboundTopic = SettingsConstants.DEFAULT_KAFKA_OUTBOUND_TOPIC;

        return outboundTopic;
    }

    public static Integer getCount() throws IOException {
        Integer count = JsonUtil.getAttribute(get(), SettingsConstants.COUNT_ATTRIBUTE_ID);

        if (count == null)
            count = SettingsConstants.DEFAULT_COUNT;

        return count;
    }

    public static Integer getWorkers() throws IOException {
        Integer workers = JsonUtil.getAttribute(get(), SettingsConstants.WORKERS_ATTRIBUTE_ID);

        if (workers == null)
            workers = SettingsConstants.DEFAULT_WORKERS;

        return workers;
    }

    public static List<Filter> getFilters() throws IOException {
        List<Map<String, Object>> result = JsonUtil.getAttribute(get(), SettingsConstants.FILTERS_ATTRIBUTE_ID);
        List<Filter> filters = null;

        if(result != null)
            filters = mapper.convertValue(result, new TypeReference<>(){});

        return filters;
    }
}
package com.akamai.ds2.converter.util;

import com.akamai.ds2.converter.util.helpers.Filter;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.StringUtils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class ConverterUtil {
    private static final String lineBreak = "\n";
    private static final ObjectMapper mapper = new ObjectMapper();

    private static String id;

    public static String getId() throws IOException{
        if (id == null) {
            try (Scanner s = new Scanner(Runtime.getRuntime().exec(new String[]{"hostname"}).getInputStream()).useDelimiter("\\A")) {
                return (s.hasNext() ? id = StringUtils.trim(s.next()) : "");
            }
        }

        return id;
    }

    public static long checkMessageReceiptDelay(long timestamp, String message) throws IOException {
        Map<String, Object> messageObject = mapper.readValue(message, new TypeReference<>(){});

        if (messageObject != null) {
            String value = (String) messageObject.get("reqTimeSec");

            if (value != null && !value.isEmpty())
                return (timestamp - (long) (Double.parseDouble(value) * 1000L));
        }

        return 0L;
    }

    public static boolean filterMessage(String message) throws IOException {
        List<Filter> filters = SettingsUtil.getFilters();
        boolean matches = true;

        if (filters != null && !filters.isEmpty()) {
            Map<String, Object> messageObject = mapper.readValue(message, new TypeReference<>(){});

            if (messageObject != null) {
                for (Filter filter : filters) {
                    Object fieldValue = JsonUtil.getAttribute(messageObject, filter.getFieldName());

                    if (fieldValue != null) {
                        Pattern pattern = Pattern.compile(filter.getRegex());
                        Matcher matcher = pattern.matcher(fieldValue.toString());

                        if (matcher.matches()) {
                            if (!filter.isInclude()) {
                                matches = false;

                                break;
                            }
                        }
                        else {
                            if (filter.isInclude()) {
                                matches = false;

                                break;
                            }
                        }
                    }
                    else {
                        if (filter.isInclude()) {
                            matches = false;

                            break;
                        }
                    }
                }
            }
            else
                matches = false;
        }

        return matches;
    }

    public static List<String> processMessages(String value) throws IOException {
        List<String> messages = null;
        Map<String, String> messageObject = mapper.readValue(value, new TypeReference<>(){});

        if (messageObject != null) {
            String message = messageObject.get("message");

            if (message != null && !message.isEmpty()) {
                String line = message;

                while (line != null && !line.isEmpty()) {
                    if (messages == null)
                        messages = new ArrayList<>();

                    int pos = line.indexOf("\n");

                    if (pos >= 0) {
                        messages.add(line.substring(0, pos));

                        line = line.substring(pos + lineBreak.length());
                    }
                    else {
                        messages.add(line);

                        line = null;
                    }
                }
            }
        }

        return messages;
    }
}

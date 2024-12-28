package com.akamai.ds2.converter.util;

import com.akamai.ds2.converter.util.helpers.Filter;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.logging.log4j.core.util.FileUtils;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class ConverterUtil {
    private static final String lineBreak = "\n";
    private static final ObjectMapper mapper = new ObjectMapper();

    public static boolean filter(String value) throws IOException {
        Map<String, Object> object = mapper.readValue(value, new TypeReference<>(){});
        List<Filter> filters = SettingsUtil.getFilters();
        boolean matches = true;

        if(filters != null && !filters.isEmpty()) {
            for (Filter filter : filters) {
                Object fieldValue = JsonUtil.getAttribute(object, filter.getFieldName());

                if (fieldValue != null) {
                    Pattern pattern = Pattern.compile(filter.getRegex());
                    Matcher matcher = pattern.matcher(fieldValue.toString());

                    if (matcher.matches()) {
                        if (!filter.isInclude()) {
                            matches = false;

                            break;
                        }
                    } else {
                        if (filter.isInclude()) {
                            matches = false;

                            break;
                        }
                    }
                } else {
                    if (filter.isInclude()) {
                        matches = false;

                        break;
                    }
                }
            }
        }

        return matches;
    }

    public static List<String> process(String value) throws IOException {
        List<String> result = null;
        Map<String, String> object = mapper.readValue(value, new TypeReference<>(){});

        if(object != null) {
            String message = object.get("message");

            if (message != null && !message.isEmpty()) {
                String line = message;

                while (line != null && !line.isEmpty()) {
                    if(result == null)
                        result = new ArrayList<>();

                    int pos = line.indexOf("\n");

                    if(pos >= 0) {
                        result.add(line.substring(0, pos));

                        line = line.substring(pos + lineBreak.length());
                    }
                    else {
                        result.add(line);

                        line = null;
                    }
                }
            }
        }

        return result;
    }
}

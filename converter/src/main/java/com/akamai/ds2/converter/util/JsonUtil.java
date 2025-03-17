package com.akamai.ds2.converter.util;

import java.util.Map;

public abstract class JsonUtil {
    @SuppressWarnings("unchecked")
    public static <O> O getAttribute(Map<String, Object> document, String attributeName) {
        String[] parts = attributeName.split("\\.");
        Map<String, Object> parentNode = document;

        for(int i = 0 ; i < (parts.length - 1); i++) {
            Object partObject = parentNode.get(parts[i]);

            if(partObject == null)
                break;

            if(partObject instanceof Map)
                parentNode = (Map<String, Object>)partObject;
            else{
                parentNode = null;

                break;
            }
        }

        if(parentNode != null)
            return (O)parentNode.get(parts[parts.length - 1]);

        return null;
    }
}
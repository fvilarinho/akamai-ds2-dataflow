package com.akamai.ds2.converter.util.helpers;

import java.io.Serializable;

public class Filter implements Serializable {
    private String fieldName;
    private String regex;
    private boolean include = false;

    public boolean isInclude() {
        return this.include;
    }

    public void setInclude(boolean include) {
        this.include = include;
    }

    public String getFieldName() {
        return this.fieldName;
    }

    public void setFieldName(String fieldName) {
        this.fieldName = fieldName;
    }

    public String getRegex() {
        return this.regex;
    }

    public void setRegex(String regex) {
        this.regex = regex;
    }
}

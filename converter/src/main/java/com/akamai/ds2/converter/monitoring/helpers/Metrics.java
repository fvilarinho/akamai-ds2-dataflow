package com.akamai.ds2.converter.monitoring.helpers;

public class Metrics {
    private long rawMessagesCount;
    private long processedMessagesCount;
    private String source;

    public Metrics() {
        super();
    }

    public Metrics(String source, long rawMessagesCount, long processedMessagesCount) {
        this();

        setSource(source);
        setRawMessagesCount(rawMessagesCount);
        setProcessedMessagesCount(processedMessagesCount);
    }

    public String getSource() {
        return this.source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public long getRawMessagesCount() {
        return this.rawMessagesCount;
    }

    public void setRawMessagesCount(long rawMessagesCount) {
        this.rawMessagesCount = rawMessagesCount;
    }

    public long getProcessedMessagesCount() {
        return this.processedMessagesCount;
    }

    public void setProcessedMessagesCount(long processedMessagesCount) {
        this.processedMessagesCount = processedMessagesCount;
    }
}

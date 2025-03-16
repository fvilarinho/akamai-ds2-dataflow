package com.akamai.ds2.converter;

import org.influxdb.InfluxDB;
import org.influxdb.InfluxDBFactory;

public class Test {
    public static void main(String[] args) {
        String url = "http://172.233.16.136:30086"; // Your InfluxDB URL
        //String username = "admin"; // Your InfluxDB username
        //tring password = "admin_password"; // Your InfluxDB password
        String database = "metrics"; // Your InfluxDB database name
        InfluxDB influxDB = InfluxDBFactory.connect(url);

        influxDB.close();
    }
}

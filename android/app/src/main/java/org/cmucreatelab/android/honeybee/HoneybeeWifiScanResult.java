package org.cmucreatelab.android.honeybee;

/**
 * Created by mike on 11/20/17.
 */

public class HoneybeeWifiScanResult {

    public String securityType;
    public String ssid;
    public String rssi;


    public HoneybeeWifiScanResult(String securityType, String ssid, String rssi) {
        this.securityType = securityType;
        this.ssid = ssid;
        this.rssi = rssi;
    }

}

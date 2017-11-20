package org.cmucreatelab.android.honeybee;

import android.os.Handler;
import android.util.Log;

import org.cmucreatelab.android.genericblemodule.serial.SerialBleHandler;

import java.util.ArrayList;

/**
 * Created by mike on 11/17/17.
 */

public class WifiScanStateMachine implements SerialBleHandler.NotificationListener {

    public enum State {
        IDLE,
        SCAN_STARTED,
        REQUESTING_WIFI_INFO,
        FINISHED_REQUESTING
    }

    private final GlobalHandler globalHandler;
    private State currentState;
    private boolean isStopped = false;
    private int numberOfWifiNetworks = 0;
    final private ArrayList<HoneybeeWifiScanResult> wifiNetworks = new ArrayList<>();


    private void requestWifiScanStart() {
        HoneybeeDevice.wifiScanStart(globalHandler.serialBleHandler, this);
    }
    private void requestWifiScanCount() {
        HoneybeeDevice.wifiScanCount(globalHandler.serialBleHandler, this);
    }
    private void requestWifiScanBroadcastInfo() {
        for (int i=0; i<numberOfWifiNetworks; i++) {
            // TODO multiple requests
            HoneybeeDevice.wifiScanQuery(globalHandler.serialBleHandler, this, i);
        }
    }


    public WifiScanStateMachine(GlobalHandler globalHandler) {
        this.globalHandler = globalHandler;
        this.currentState = State.IDLE;
    }


    public void start() {
        this.wifiNetworks.clear();
        requestWifiScanStart();
        //this.currentState = State.SCAN_STARTED;
    }
    public void stop() {
        isStopped = true;
    }


    @Override
    public void onNotificationReceived(String messageSent, String response) {
        Log.i(MainActivity.LOG_TAG, messageSent + " => " + response);
        String[] args = response.split(",", -1);

        switch (currentState) {
            case IDLE:
                if (!args[0].equals("S") || args.length != 2) {
                    Log.e(MainActivity.LOG_TAG, "bad format on state IDLE");
                    stop();
                } else {
                    this.currentState = State.SCAN_STARTED;
                    requestWifiScanCount();
                }
                break;
            case SCAN_STARTED:
                if (!args[0].equals("S") || args.length != 3) {
                    Log.e(MainActivity.LOG_TAG, "bad format on state SCAN_STARTED");
                } else {
                    int num = Integer.parseInt(args[1]);
                    if (num>0) {
                        this.numberOfWifiNetworks = num;
                        this.currentState = State.REQUESTING_WIFI_INFO;
                        requestWifiScanBroadcastInfo();
                    } else {
                        globalHandler.mainActivity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Handler handler = new Handler();
                                Runnable runnable = new Runnable() {
                                    @Override
                                    public void run() {
                                        HoneybeeDevice.wifiScanCount(globalHandler.serialBleHandler, WifiScanStateMachine.this);
                                    }
                                };
                                handler.postDelayed(runnable, 500);
                            }
                        });
                    }
                }
                break;
            case REQUESTING_WIFI_INFO:
                // check format
                if (!args[0].equals("S") || args.length != 6) {
                    Log.e(MainActivity.LOG_TAG, "bad format on state SCAN_STARTED");
                } else {
                    int index = Integer.valueOf(args[1]);
                    // add network to list
                    String securityType = args[2];
                    String ssid = args[3];
                    String rssi = args[4];
                    wifiNetworks.add(new HoneybeeWifiScanResult(securityType, ssid, rssi));

                    // if this is the last index, we finish
                    if (numberOfWifiNetworks == index+1) {
                        if (wifiNetworks.size() == numberOfWifiNetworks) {
                            this.currentState = State.FINISHED_REQUESTING;
                        } else {
                            Log.e(MainActivity.LOG_TAG, "size of wifi list does not match wifi count from BLE.");
                        }
                        JavaScriptInterface.notifyNetworkListChanged(globalHandler.mainActivity, wifiNetworks);
                        stop();
                    }
                }
                break;
            default:
                Log.w(MainActivity.LOG_TAG, "WifiScanStateMachine Ended in unknown state");
                JavaScriptInterface.notifyNetworkListChanged(globalHandler.mainActivity, wifiNetworks);
                stop();
        }
    }

}

package org.cmucreatelab.android.honeybee;

import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.util.Log;
import android.widget.Toast;

import org.cmucreatelab.android.genericblemodule.serial.SerialBleHandler;

import java.util.List;

/**
 * Created by mike on 8/10/17.
 */

public class ApplicationInterface {


    private static void bleScan(GlobalHandler globalHandler, boolean enabled) {
        // TODO add a callback when the timer expires and scanning stops?
        if (enabled) {
            Log.v(MainActivity.LOG_TAG, "ble scan turn on");
            globalHandler.mainActivity.bleDevices.clear();
            globalHandler.genericBleScanner.enableBluetooth(globalHandler.mainActivity);
        } else {
            Log.v(MainActivity.LOG_TAG, "ble scan OFF");
        }
        globalHandler.genericBleScanner.scanLeDevice(enabled, globalHandler.mainActivity.leScanCallback);
    }


    private static void connectDevice(GlobalHandler globalHandler, int deviceId) {
        int listSize = globalHandler.mainActivity.bleDevices.size();
        if (deviceId < listSize) {
            BluetoothDevice device = globalHandler.mainActivity.bleDevices.get(deviceId);
            globalHandler.connectDevice(device);
        } else {
            Log.e(MainActivity.LOG_TAG, "cannot connect device with deviceId="+deviceId+" and list size="+listSize);
        }
    }


    private static void requestDeviceInfo(final GlobalHandler globalHandler) {
        SerialBleHandler.NotificationListener notificationListener = new SerialBleHandler.NotificationListener() {
            @Override
            public void onNotificationReceived(String messageSent, String response) {
                Log.i(MainActivity.LOG_TAG, messageSent + " => " + response);
                String[] args = response.split(",");
                if (!args[0].equals("I") || args.length != 8) {
                    Log.e(MainActivity.LOG_TAG, "Got a bad response from command I: response="+response);
                } else {
                    String hwVersion = args[2], fwVersion = args[3], deviceName = args[4], serialNumber = args[5];
                    JavaScriptInterface.populateDeviceInfo(globalHandler.mainActivity, deviceName, hwVersion, fwVersion, serialNumber);
                }
            }
        };

        HoneybeeDevice.requestDeviceInfo(globalHandler.serialBleHandler, notificationListener);
    }


    // TODO scanning should be treated as a request instead of a switch (on/off)
    private static void wifiScan(final GlobalHandler globalHandler, boolean enabled) {
        Log.v(MainActivity.LOG_TAG, "wifiScan enabled="+enabled);
        if (enabled) {
            final WifiManager wifiManager = (WifiManager) globalHandler.mainActivity.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
            // turn on wifi is not on
            if (!wifiManager.isWifiEnabled()) {
                wifiManager.setWifiEnabled(true);
            }
            // start scan and list the results
            if (wifiManager.startScan()) {
                globalHandler.mainActivity.registerReceiver(new BroadcastReceiver() {
                    @Override
                    public void onReceive(Context context, Intent intent) {
                        Log.v(MainActivity.LOG_TAG, "SCAN_RESULTS_AVAILABLE_ACTION");
                        List<ScanResult> results = wifiManager.getScanResults();
                        for (ScanResult result : results) {
                            Log.v(MainActivity.LOG_TAG, "scan item: " + result.SSID + " " + result.level + " // " + result.capabilities + " (" + result.BSSID + ")");
                        }
                        globalHandler.mainActivity.unregisterReceiver(this);
                        JavaScriptInterface.notifyNetworkListChanged(globalHandler.mainActivity, results);
                    }
                }, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
            } else {
                Log.e(MainActivity.LOG_TAG, "WifiManager failed to start scan.");
            }
        }
    }


    public static void parseSchema(final GlobalHandler globalHandler, String functionName, String[] params) {
        switch(functionName) {
            case "bleScan":
                if (params.length == 1) {
                    boolean enabled = Boolean.valueOf(params[0]);
                    bleScan(globalHandler, enabled);
                } else {
                    Log.e(MainActivity.LOG_TAG, "bad number of parameters for function "+functionName+"; params size="+params.length);
                }
                break;
            case "connectDevice":
                if (params.length == 1) {
                    int deviceId = Integer.valueOf(params[0]);
                    connectDevice(globalHandler, deviceId);
                } else {
                    Log.e(MainActivity.LOG_TAG, "bad number of parameters for function "+functionName+"; params size="+params.length);
                }
                break;
            case "requestDeviceInfo":
                if (params.length == 1 && params[0].equals("")) {
                    requestDeviceInfo(globalHandler);
                } else {
                    Log.e(MainActivity.LOG_TAG, "bad number of parameters for function "+functionName+"; params size="+params.length);
                }
                break;
            case "wifiScan":
                if (params.length == 1) {
                    boolean enabled = Boolean.valueOf(params[0]);
                    wifiScan(globalHandler, enabled);
                } else {
                    Log.e(MainActivity.LOG_TAG, "bad number of parameters for function "+functionName+"; params size="+params.length);
                }
                break;
            default:
                Log.e(MainActivity.LOG_TAG, "failed to parse function name="+functionName);
        }
    }

}

package org.cmucreatelab.android.honeybee;

import android.bluetooth.BluetoothDevice;
import android.util.Log;

import org.cmucreatelab.android.genericblemodule.serial.SerialBleHandler;

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
            default:
                Log.e(MainActivity.LOG_TAG, "failed to parse function name="+functionName);
        }
    }

}

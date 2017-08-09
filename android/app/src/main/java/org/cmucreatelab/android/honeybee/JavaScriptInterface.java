package org.cmucreatelab.android.honeybee;

import android.bluetooth.BluetoothDevice;
import android.net.Uri;
import android.util.Log;
import android.webkit.WebView;

import org.cmucreatelab.android.genericblemodule.generic_ble.GenericBleScanner;

import java.util.ArrayList;

/**
 * Created by mike on 8/9/17.
 */

public class JavaScriptInterface {


    private static void bleScan(GlobalHandler globalHandler, boolean enabled) {
        // TODO add a callback when the timer expires and scanning stops?
        if (enabled) {
            Log.v(MainActivity.LOG_TAG, "ble scan turn on");
            GenericBleScanner genericBleScanner = globalHandler.genericBleScanner;
            genericBleScanner.enableBluetooth(globalHandler.mainActivity);
            genericBleScanner.scanLeDevice(true, globalHandler.mainActivity.leScanCallback);
        } else {
            Log.v(MainActivity.LOG_TAG, "ble scan OFF");
            globalHandler.mainActivity.bleDevices.clear();
            globalHandler.genericBleScanner.scanLeDevice(false, globalHandler.mainActivity.leScanCallback);
        }
    }


    public static void notifyDeviceListChanged(final WebView view, ArrayList<BluetoothDevice> newList) {
        // TODO need to consider escape characters \" in device name and address
        String jsArray = "[";
        for (BluetoothDevice device: newList) {
            jsArray += "{name: \"" + device.getName() + "\", mac_address: \"" + device.getAddress() + "\"},";
        }
        jsArray += "]";
        view.loadUrl("javascript:Page1A.notifyDeviceListChanged("+ Uri.encode(jsArray) +")");
    }


    public static void parseSchema(final GlobalHandler globalHandler, String functionName, String[] params) {
        switch(functionName) {
            case "bleScan":
                if (params.length == 1) {
                    boolean enabled = Boolean.valueOf(params[0]);
                    bleScan(globalHandler, enabled);
                } else {
                    Log.e(MainActivity.LOG_TAG, "bad number of parameters for bleScan function; params size="+params.length);
                }
                break;
            default:
                Log.e(MainActivity.LOG_TAG, "failed to parse function name="+functionName);
        }
    }

}

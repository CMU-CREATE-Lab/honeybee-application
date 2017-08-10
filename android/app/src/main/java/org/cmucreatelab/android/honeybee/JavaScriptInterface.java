package org.cmucreatelab.android.honeybee;

import android.bluetooth.BluetoothDevice;
import android.net.Uri;
import android.webkit.WebView;

import java.util.ArrayList;

/**
 * Created by mike on 8/9/17.
 */

public class JavaScriptInterface {


    public static void notifyDeviceListChanged(final WebView view, ArrayList<BluetoothDevice> newList) {
        // TODO need to consider escape characters \" in device name and address
        String jsArray = "[";
        for (BluetoothDevice device: newList) {
            jsArray += "{name: \"" + device.getName() + "\", mac_address: \"" + device.getAddress() + "\"},";
        }
        jsArray += "]";
        view.loadUrl("javascript:Page1A.notifyDeviceListChanged("+ Uri.encode(jsArray) +")");
    }

}

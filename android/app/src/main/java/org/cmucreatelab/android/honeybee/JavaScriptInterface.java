package org.cmucreatelab.android.honeybee;

import android.bluetooth.BluetoothDevice;
import android.net.Uri;
import android.util.Log;
import android.webkit.WebView;

import java.util.ArrayList;

/**
 * Created by mike on 8/9/17.
 */

public class JavaScriptInterface {


    public static void notifyDeviceListChanged(final WebView webView, ArrayList<BluetoothDevice> newList) {
        // TODO need to consider escape characters \" in device name and address
        String jsArray = "[";
        for (BluetoothDevice device: newList) {
            jsArray += "{name: \"" + device.getName() + "\", mac_address: \"" + device.getAddress() + "\"},";
        }
        jsArray += "]";
        sendJavaScript(webView, "Page1A.notifyDeviceListChanged("+ Uri.encode(jsArray) +")");
    }


    private static void sendJavaScript(final WebView webView, String script) {
        String url = "javascript:" + script;
        Log.v(MainActivity.LOG_TAG, "sendJavaScript: ``"+url+"``");
        webView.loadUrl(url);
    }

}

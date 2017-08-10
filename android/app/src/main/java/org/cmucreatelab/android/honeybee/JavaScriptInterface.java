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


    public static void notifyDeviceListChanged(final MainActivity mainActivity, ArrayList<BluetoothDevice> newList) {
        // TODO need to consider escape characters \" in device name and address
        String jsArray = "[";
        for (int i=0; i<newList.size(); i++) {
            BluetoothDevice device = newList.get(i);
            jsArray += "{name: \"" + device.getName() + "\", mac_address: \"" + device.getAddress() + "\", device_id: "+ i +"},";
        }
        jsArray += "]";
        sendJavaScript(mainActivity, "Page1A.notifyDeviceListChanged("+ Uri.encode(jsArray) +")");
    }


    public static void onDeviceConnected(final MainActivity mainActivity, BluetoothDevice device) {
        // TODO need to consider escape characters \" in device name and address
        String json = "{";
        json += "name: \"" + device.getName() + "\",";
        json += "mac_address: \"" + device.getAddress() + "\",";
        json += "}";
        sendJavaScript(mainActivity, "Page1A.onDeviceConnected(" + Uri.encode(json) + ")");
    }


    public static void populateDeviceInfo(final MainActivity mainActivity, String name, String hw, String fw, String serial) {
        String params = "";
        params += "\"" + name + "\", ";
        params += "\"" + hw + "\", ";
        params += "\"" + fw + "\", ";
        params += "\"" + serial + "\"";
        sendJavaScript(mainActivity, "Page1B.populateDeviceInfo(" + Uri.encode(params) + ")");
    }


    private static void sendJavaScript(final MainActivity mainActivity, String script) {
        final String url = "javascript:" + script;
        mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.v(MainActivity.LOG_TAG, "sendJavaScript: ``"+url+"``");
                mainActivity.webView.loadUrl(url);
            }
        });
    }

}

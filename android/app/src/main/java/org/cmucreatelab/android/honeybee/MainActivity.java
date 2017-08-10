package org.cmucreatelab.android.honeybee;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {

    public WebView webView;
    public static final String LOG_TAG = "Honeybee";
    public final ArrayList<BluetoothDevice> bleDevices = new ArrayList<>();
    public BluetoothAdapter.LeScanCallback leScanCallback = new BluetoothAdapter.LeScanCallback() {
        @Override
        public void onLeScan(BluetoothDevice bluetoothDevice, int i, byte[] bytes) {
            if (!bleDevices.contains(bluetoothDevice)) {
                Log.v(LOG_TAG, "found new device: " + bluetoothDevice.getName());
                bleDevices.add(bluetoothDevice);
                JavaScriptInterface.notifyDeviceListChanged(MainActivity.this, bleDevices);
            }
        }
    };


    @Override
    public void onBackPressed() {
        // TODO this needs to be overridden to avoid users accidentally closing the app
        super.onBackPressed();
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.v(LOG_TAG, "onCreate");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        this.webView = (WebView) findViewById(R.id.webView);
        webView.setWebViewClient(new CustomWebViewClient(this));
        webView.getSettings().setJavaScriptEnabled(true);
        webView.loadUrl("file:///android_asset/web/index.html");
    }


    @Override
    protected void onPause() {
        Log.v(LOG_TAG, "onPause");
        super.onPause();
    }


    @Override
    protected void onResume() {
        Log.v(LOG_TAG, "onResume");
        super.onResume();
    }

}

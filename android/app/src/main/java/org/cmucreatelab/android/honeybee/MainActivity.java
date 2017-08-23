package org.cmucreatelab.android.honeybee;

import android.app.AlertDialog;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.DialogInterface;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.webkit.WebView;
import android.widget.EditText;

import org.cmucreatelab.android.genericblemodule.generic_ble.GenericBleScanner;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {

    public WebView webView;
    public static final String LOG_TAG = "Honeybee";
    public final ArrayList<BluetoothDevice> bleDevices = new ArrayList<>();
    public GenericBleScanner.ScannerCallback scannerCallback = new GenericBleScanner.ScannerCallback() {
        @Override
        public void onScanTimerExpired() {
            Log.v(LOG_TAG, "onScanTimerExpired()");
            JavaScriptInterface.setScanning(MainActivity.this, false);
        }

        @Override
        public void onLeScan(BluetoothDevice bluetoothDevice, int i, byte[] bytes) {
            if (!bleDevices.contains(bluetoothDevice)) {
                Log.v(LOG_TAG, "found new device: " + bluetoothDevice.getName());
                bleDevices.add(bluetoothDevice);
                JavaScriptInterface.notifyDeviceListChanged(MainActivity.this, bleDevices);
            }
        }
    };


    public interface NetworkPasswordDialogListener {
        void onClick(String password);
    }


    // NOTE: dialogView, listener, and message can be null
    private void displayAndCreateDialog(View dialogView, String positiveButtonText, DialogInterface.OnClickListener listener, String title, String message) {
        final AlertDialog.Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(this, R.style.AppTheme));

        // check if null before setting
        builder.setTitle(title);
        if (dialogView != null) builder.setView(dialogView);
        if (message != null) builder.setMessage(message);

        // set button and listener (can be null)
        builder.setPositiveButton(positiveButtonText, listener);

        // create and show dialog
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                builder.create();
                builder.show();
            }
        });
    }


    public void displayNetworkPasswordDialog(String ssid, final NetworkPasswordDialogListener listener) {
        LayoutInflater inflater = getLayoutInflater();
        final View view = inflater.inflate(R.layout.dialog_password, null);
        DialogInterface.OnClickListener dialogListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                String password = ((EditText)view.findViewById(R.id.textFieldPassword)).getText().toString();
                listener.onClick(password);
            }
        };

        displayAndCreateDialog(view, "OK", dialogListener, "Enter Password for network "+ssid, null);
    }


    public void displayNetworkErrorDialog(String message) {
        displayAndCreateDialog(null, "OK", null, "Failed to Join Network", message);
    }


    public void displayBleErrorDialog(String message) {
        displayAndCreateDialog(null, "OK", null, "Bluetooth Error", message);
    }


    public void displayGeneralErrorDialog(String message) {
        displayAndCreateDialog(null, "OK", null, "Application Error", message);
    }


    @Override
    public void onBackPressed() {
        // NOTE: this method isn't triggered a dialog is displayed
        Log.v(LOG_TAG, "MainActivity.onBackPressed()");

        String title = "Honeybee";
        String message = "Close Application?";
        DialogInterface.OnClickListener clickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                // TODO cleanup on app closing
                finish();
            }
        };
        final AlertDialog.Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(this, R.style.AppTheme));

        builder.setTitle(title);
        builder.setMessage(message);
        builder.setPositiveButton("OK", clickListener);
        builder.setNegativeButton("Cancel", null);
        builder.setCancelable(false);

        // create and show dialog
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                builder.create();
                builder.show();
            }
        });
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

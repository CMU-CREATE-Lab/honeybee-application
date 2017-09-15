package org.cmucreatelab.android.honeybee;

import android.Manifest;
import android.app.AlertDialog;
import android.bluetooth.BluetoothDevice;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
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
    private static final int REQUEST_CODE_ACCESS_FINE_LOCATION = 1;
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
            if (!bluetoothDeviceHasValidHoneybeeName(bluetoothDevice)) {
                Log.w(LOG_TAG, "Not adding bluetooth device with name="+bluetoothDevice.getName());
                return;
            }
            if (!bleDevices.contains(bluetoothDevice)) {
                bleDevices.add(bluetoothDevice);
                JavaScriptInterface.notifyDeviceListChanged(MainActivity.this, bleDevices);
            }
        }
    };


    public interface NetworkPasswordDialogListener {
        void onClick(String password);
    }


    private boolean bluetoothDeviceHasValidHoneybeeName(BluetoothDevice bluetoothDevice) {
        String name = bluetoothDevice.getName();
        if (name != null && name.length() > 2) {
            if (bluetoothDevice.getName().substring(0,2).equals("HB"))
                return true;
        }
        return false;
    }


    // NOTE: dialogView, listener, and message can be null
    private void createAndDisplayDialog(View dialogView, String positiveButtonText, DialogInterface.OnClickListener listener, String title, String message) {
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


    // NOTE: listeners can be null
    private void createAndDisplayDialogWithChoice(String positiveButtonText, DialogInterface.OnClickListener positiveListener, String negativeButtonText, DialogInterface.OnClickListener negativeListener, String title, String message) {
        final AlertDialog.Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(this, R.style.AppTheme));

        // check if null before setting
        builder.setTitle(title);
        builder.setMessage(message);

        builder.setTitle(title);
        builder.setMessage(message);
        builder.setPositiveButton(positiveButtonText, positiveListener);
        builder.setNegativeButton(negativeButtonText, negativeListener);
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


    private void checkAndRequestLocationPermission() {
        if (ContextCompat.checkSelfPermission(this, "android.permission.ACCESS_FINE_LOCATION") != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, REQUEST_CODE_ACCESS_FINE_LOCATION);
        }
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

        createAndDisplayDialog(view, "OK", dialogListener, "Enter Password for network "+ssid, null);
    }


    public void displayNetworkErrorDialog(String message) {
        createAndDisplayDialog(null, "OK", null, "Failed to Join Network", message);
    }


    public void displayBleErrorDialog(String message) {
        createAndDisplayDialog(null, "OK", null, "Bluetooth Error", message);
    }


    public void displayGeneralErrorDialog(String message) {
        createAndDisplayDialog(null, "OK", null, "Application Error", message);
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

        createAndDisplayDialogWithChoice("OK", clickListener, "Cancel", null, title, message);
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.v(LOG_TAG, "onCreate");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // ACCESS_FINE_LOCATION: only ask if permission not granted (android api level 23 or higher)
        checkAndRequestLocationPermission();

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

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == REQUEST_CODE_ACCESS_FINE_LOCATION) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.v(LOG_TAG, "onRequestPermissionsResult: PERMISSION GRANTED");
            } else {
                Log.v(LOG_TAG, "onRequestPermissionsResult: PERMISSION DENIED");
                String title = "NEED LOCATION PERMISSION";
                String message = "In newer versions of Android, applications that perform Bluetooth scanning require location permissions. Please allow location access for this application to continue.";
                String button1 = "Retry", button2 = "Close Application";
                DialogInterface.OnClickListener listener1 = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        checkAndRequestLocationPermission();
                    }
                }, listener2 = new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        finish();
                    }
                };

                createAndDisplayDialogWithChoice(button1, listener1, button2, listener2, title, message);
            }
        } else {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

}

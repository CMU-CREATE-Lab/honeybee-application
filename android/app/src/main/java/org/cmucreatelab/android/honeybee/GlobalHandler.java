package org.cmucreatelab.android.honeybee;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.util.Log;

import org.cmucreatelab.android.genericblemodule.ble_actions.ActionCharacteristicSetNotification;
import org.cmucreatelab.android.genericblemodule.generic_ble.GenericBleScanner;
import org.cmucreatelab.android.genericblemodule.serial.SerialBleHandler;

import java.util.UUID;

/**
 * Created by mike on 7/5/17.
 */

public class GlobalHandler {

    private static GlobalHandler instance;
    public MainActivity mainActivity;
    public final SerialBleHandler serialBleHandler;
    public GenericBleScanner genericBleScanner;

    private GlobalHandler(MainActivity mainActivity) {
        this.mainActivity = mainActivity;
        this.serialBleHandler = new SerialBleHandler(mainActivity);
        this.genericBleScanner = serialBleHandler.getScanner();
    }

    public static GlobalHandler getInstance(MainActivity mainActivity) {
        if (instance == null) {
            instance = new GlobalHandler(mainActivity);
        }
        return instance;
    }

    public void connectDevice(final BluetoothDevice device) {
        serialBleHandler.connectDevice(device, new SerialBleHandler.ConnectionListener() {
            private boolean timedOut = false;
            @Override
            public void onConnected(BluetoothGatt gatt) {
                Log.i(MainActivity.LOG_TAG, "discovered services");
                if (timedOut) {
                    Log.e(MainActivity.LOG_TAG, "discovered services but timedOut");
                    return;
                }

                // NOTE: readCharacteristic and setCharacteristicNotification are asynchronous; calling them one after another will not work.
                // instead, you have to wait for each one to finish before going on to the next one.
                UUID service,serviceChar;

                // set up notifications
                service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
                serviceChar = UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e");
                final BluetoothGattCharacteristic characteristic = gatt.getService(service).getCharacteristic(serviceChar);
                final int charaProp = characteristic.getProperties();
                // ASSERT: this is true
                if ((charaProp | BluetoothGattCharacteristic.PROPERTY_NOTIFY) > 0) {
                    setCharacteristicNotification(characteristic, true);
                }

                JavaScriptInterface.onDeviceConnected(mainActivity, device);
            }

            @Override
            public void onTimeout() {
                timedOut = true;
                Log.w(MainActivity.LOG_TAG, "connectDevice onTimeout");
                // TODO callback to HTML and stop connection spinner
            }
        });
    }

    public void setCharacteristicNotification(BluetoothGattCharacteristic characteristic,
                                              boolean enabled) {
        // This is specific to our BLE device.
        BluetoothGattDescriptor descriptor = characteristic.getDescriptor(
                UUID.fromString("00002902-0000-1000-8000-00805f9b34fb"));
        serialBleHandler.getDeviceConnection().send(new ActionCharacteristicSetNotification(characteristic, descriptor, enabled));
    }

}

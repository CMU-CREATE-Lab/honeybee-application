package org.cmucreatelab.android.honeybee;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;

import org.cmucreatelab.android.genericblemodule.serial.SerialBleHandler;

import java.util.UUID;

/**
 * Created by mike on 8/10/17.
 */

public class HoneybeeDevice {


    public static void requestDeviceInfo(SerialBleHandler serialBleHandler, SerialBleHandler.NotificationListener notificationListener) {
        UUID service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
        UUID serviceChar = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

        BluetoothGattService bleService = serialBleHandler.getDeviceConnection().getService(service);
        BluetoothGattCharacteristic bleCharacteristic = bleService.getCharacteristic(serviceChar);
        BluetoothGattCharacteristic bleNotifyCharacteristic = bleService.getCharacteristic(UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"));

        serialBleHandler.sendMessageForResult(bleCharacteristic, bleNotifyCharacteristic, "I", notificationListener);
    }


    public static void requestJoinNetwork(SerialBleHandler serialBleHandler, SerialBleHandler.NotificationListener notificationListener, int securityType, String ssid, String key) {
        UUID service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
        UUID serviceChar = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

        BluetoothGattService bleService = serialBleHandler.getDeviceConnection().getService(service);
        BluetoothGattCharacteristic bleCharacteristic = bleService.getCharacteristic(serviceChar);
        BluetoothGattCharacteristic bleNotifyCharacteristic = bleService.getCharacteristic(UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"));

        String message = "J,"+securityType+","+ssid+","+key;

        serialBleHandler.sendMessageForResult(bleCharacteristic, bleNotifyCharacteristic, message, notificationListener);
    }


    public static void requestNetworkInfo(SerialBleHandler serialBleHandler, SerialBleHandler.NotificationListener notificationListener) {
        UUID service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
        UUID serviceChar = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

        BluetoothGattService bleService = serialBleHandler.getDeviceConnection().getService(service);
        BluetoothGattCharacteristic bleCharacteristic = bleService.getCharacteristic(serviceChar);
        BluetoothGattCharacteristic bleNotifyCharacteristic = bleService.getCharacteristic(UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"));

        serialBleHandler.sendMessageForResult(bleCharacteristic, bleNotifyCharacteristic, "W", notificationListener);
    }

}

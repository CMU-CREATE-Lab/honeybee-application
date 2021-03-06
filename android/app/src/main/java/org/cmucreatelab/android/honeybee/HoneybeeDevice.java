package org.cmucreatelab.android.honeybee;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;

import org.cmucreatelab.android.genericblemodule.serial.SerialBleHandler;

import java.util.UUID;

/**
 * Created by mike on 8/10/17.
 *
 * Helper for making requests to a previously-connected BluetoothDevice; see protocol document for details.
 */
public class HoneybeeDevice {


    // TODO handle state when the device was already disconnected


    public static void requestDeviceInfo(SerialBleHandler serialBleHandler, SerialBleHandler.NotificationListener notificationListener) {
        UUID service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
        UUID serviceChar = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

        BluetoothGattService bleService = serialBleHandler.getDeviceConnection().getService(service);
        BluetoothGattCharacteristic bleCharacteristic = bleService.getCharacteristic(serviceChar);
        BluetoothGattCharacteristic bleNotifyCharacteristic = bleService.getCharacteristic(UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"));

        serialBleHandler.sendMessageForResult(bleCharacteristic, bleNotifyCharacteristic, "I", notificationListener);
    }


    public static void requestNetworkInfo(SerialBleHandler serialBleHandler, SerialBleHandler.NotificationListener notificationListener) {
        UUID service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
        UUID serviceChar = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

        BluetoothGattService bleService = serialBleHandler.getDeviceConnection().getService(service);
        BluetoothGattCharacteristic bleCharacteristic = bleService.getCharacteristic(serviceChar);
        BluetoothGattCharacteristic bleNotifyCharacteristic = bleService.getCharacteristic(UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"));

        serialBleHandler.sendMessageForResult(bleCharacteristic, bleNotifyCharacteristic, "W", notificationListener);
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


    public static void requestRemoveNetwork(SerialBleHandler serialBleHandler, SerialBleHandler.NotificationListener notificationListener) {
        UUID service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
        UUID serviceChar = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

        BluetoothGattService bleService = serialBleHandler.getDeviceConnection().getService(service);
        BluetoothGattCharacteristic bleCharacteristic = bleService.getCharacteristic(serviceChar);
        BluetoothGattCharacteristic bleNotifyCharacteristic = bleService.getCharacteristic(UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"));

        serialBleHandler.sendMessageForResult(bleCharacteristic, bleNotifyCharacteristic, "R", notificationListener);
    }


    public static void setFeedKey(SerialBleHandler serialBleHandler, SerialBleHandler.NotificationListener notificationListener, boolean enabled, String key) {
        UUID service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
        UUID serviceChar = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

        BluetoothGattService bleService = serialBleHandler.getDeviceConnection().getService(service);
        BluetoothGattCharacteristic bleCharacteristic = bleService.getCharacteristic(serviceChar);
        BluetoothGattCharacteristic bleNotifyCharacteristic = bleService.getCharacteristic(UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"));

        String message = "K,"+ (enabled ? "1,"+key : "0");

        serialBleHandler.sendMessageForResult(bleCharacteristic, bleNotifyCharacteristic, message, notificationListener);
    }


    public static void wifiScanStart(SerialBleHandler serialBleHandler, SerialBleHandler.NotificationListener notificationListener) {
        UUID service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
        UUID serviceChar = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

        BluetoothGattService bleService = serialBleHandler.getDeviceConnection().getService(service);
        BluetoothGattCharacteristic bleCharacteristic = bleService.getCharacteristic(serviceChar);
        BluetoothGattCharacteristic bleNotifyCharacteristic = bleService.getCharacteristic(UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"));

        String message = "S,start";

        serialBleHandler.sendMessageForResult(bleCharacteristic, bleNotifyCharacteristic, message, notificationListener);
    }


    public static void wifiScanCount(SerialBleHandler serialBleHandler, SerialBleHandler.NotificationListener notificationListener) {
        UUID service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
        UUID serviceChar = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

        BluetoothGattService bleService = serialBleHandler.getDeviceConnection().getService(service);
        BluetoothGattCharacteristic bleCharacteristic = bleService.getCharacteristic(serviceChar);
        BluetoothGattCharacteristic bleNotifyCharacteristic = bleService.getCharacteristic(UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"));

        String message = "S,count";

        serialBleHandler.sendMessageForResult(bleCharacteristic, bleNotifyCharacteristic, message, notificationListener);
    }


    public static void wifiScanQuery(SerialBleHandler serialBleHandler, SerialBleHandler.NotificationListener notificationListener, int index) {
        UUID service = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
        UUID serviceChar = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

        BluetoothGattService bleService = serialBleHandler.getDeviceConnection().getService(service);
        BluetoothGattCharacteristic bleCharacteristic = bleService.getCharacteristic(serviceChar);
        BluetoothGattCharacteristic bleNotifyCharacteristic = bleService.getCharacteristic(UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"));

        String message = "S," + String.valueOf(index);

        serialBleHandler.sendMessageForResult(bleCharacteristic, bleNotifyCharacteristic, message, notificationListener);
    }

}

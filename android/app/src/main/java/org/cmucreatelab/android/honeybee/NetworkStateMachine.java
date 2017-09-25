package org.cmucreatelab.android.honeybee;

import android.util.Log;

import org.cmucreatelab.android.genericblemodule.serial.SerialBleHandler;

/**
 * Created by mike on 8/11/17.
 *
 * Tracks the current state of the Honeybee Device's network connection.
 */
public class NetworkStateMachine implements SerialBleHandler.NotificationListener {

    public enum State {
        IDLE,
        CANNOT_SEE_NETWORK,
        JOIN_FAILED,
        AUTHENTICATION_FAILED,
        ASSOCIATION_FAILED,
        JOINING,
        CONNECTED
    }

    private final GlobalHandler globalHandler;
    private State currentState;
    private boolean isStopped = false;


    private static State findStateFromString(String status) {
        if (status.equals("0")) return State.IDLE;
        if (status.equals("1")) return State.CANNOT_SEE_NETWORK;
        if (status.equals("2")) return State.JOIN_FAILED;
        if (status.equals("3")) return State.AUTHENTICATION_FAILED;
        if (status.equals("4")) return State.ASSOCIATION_FAILED;
        if (status.equals("5")) return State.JOINING;
        if (status.equals("6")) return State.CONNECTED;

        Log.e(MainActivity.LOG_TAG, "could not parse status="+status+"; returning IDLE state.");
        return State.IDLE;
    }


    private void requestNetworkInfo() {
        HoneybeeDevice.requestNetworkInfo(globalHandler.serialBleHandler, this);
    }


    public NetworkStateMachine(GlobalHandler globalHandler) {
        this.globalHandler = globalHandler;
        this.currentState = State.IDLE;
    }


    public void start() {
        Log.v(MainActivity.LOG_TAG, "NetworkStateMachine.start");
        requestNetworkInfo();
    }


    public void stop() {
        this.isStopped = true;
    }


    public void terminateWithMessage(String message) {
        Log.e(MainActivity.LOG_TAG, "NetworkStateMachine.terminateWithMessage: "+message);
        stop();
        HoneybeeDevice.requestRemoveNetwork(globalHandler.serialBleHandler, new SerialBleHandler.NotificationListener() {
            @Override
            public void onNotificationReceived(String messageSent, String response) {
                JavaScriptInterface.onNetworkDisconnected(globalHandler.mainActivity);
            }
        });
        globalHandler.mainActivity.displayNetworkErrorDialog(message);
    }


    @Override
    public void onNotificationReceived(String messageSent, String response) {
        if (isStopped) {
            Log.i(MainActivity.LOG_TAG, "ignoring message response since NetworkStateMachine is stopped.");
            return;
        }
        Log.i(MainActivity.LOG_TAG, messageSent + " => " + response);
        String[] args = response.split(",", -1);
        if (args.length != 7) {
            Log.e(MainActivity.LOG_TAG, "Received bad number of args from W request; backing out.");
        }

        String status = args[1], macAddress = args[2], ipAddress = args[3], networkSaved = args[4], securityType = args[5], ssid = args[6];
        this.currentState = findStateFromString(status);
        switch (currentState) {
            case CANNOT_SEE_NETWORK:
                terminateWithMessage("Cannot see network");
                break;
            case JOIN_FAILED:
                terminateWithMessage("Failed to join network");
                break;
            case AUTHENTICATION_FAILED:
                terminateWithMessage("Authentication failed");
                break;
            case ASSOCIATION_FAILED:
                terminateWithMessage("Association failed");
                break;
            case JOINING:
                // keep requesting network info
                requestNetworkInfo();
                break;
            case CONNECTED:
                JavaScriptInterface.populateNetworkInfo(globalHandler.mainActivity, ssid, ipAddress, macAddress);
                break;
            case IDLE:
            default:
                Log.w(MainActivity.LOG_TAG, "NetworkStateMachine Ended in idle or unknown state");
                terminateWithMessage("Unknown Error");
        }
    }

}

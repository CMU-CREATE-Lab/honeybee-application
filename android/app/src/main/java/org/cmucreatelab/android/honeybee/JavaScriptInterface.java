package org.cmucreatelab.android.honeybee;

import android.util.Log;

/**
 * Created by mike on 8/9/17.
 */

public class JavaScriptInterface {

    
    private static void bleScan(boolean enabled) {
        if (enabled) {
            Log.v(MainActivity.LOG_TAG, "ble scan turn on");
        } else {
            Log.v(MainActivity.LOG_TAG, "ble scan OFF");
        }
    }


    public static void parseSchema(String functionName, String[] params) {
        switch(functionName) {
            case "bleScan":
                if (params.length == 1) {
                    boolean param1 = Boolean.valueOf(params[0]);
                    bleScan(param1);
                } else {
                    Log.e(MainActivity.LOG_TAG, "bad number of parameters for bleScan function; params size="+params.length);
                }
                break;
            default:
                Log.e(MainActivity.LOG_TAG, "failed to parse function name="+functionName);
        }
    }

}

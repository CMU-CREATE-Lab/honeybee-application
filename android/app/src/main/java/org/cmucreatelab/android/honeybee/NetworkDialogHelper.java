package org.cmucreatelab.android.honeybee;

import android.text.InputType;
import android.text.method.PasswordTransformationMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.RadioGroup;

/**
 * Created by mike on 9/22/17.
 *
 * Helper for creating dialogs for configuring network.
 */
public class NetworkDialogHelper {


    public static View createInstance(MainActivity mainActivity) {
        LayoutInflater inflater = mainActivity.getLayoutInflater();
        View view = inflater.inflate(R.layout.dialog_network, null);

        final EditText textFieldPassword = ((EditText)view.findViewById(R.id.textFieldPassword));
        ((CheckBox)view.findViewById(R.id.checkBoxShowPassword)).setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                textFieldPassword.setInputType(b ? InputType.TYPE_CLASS_TEXT : InputType.TYPE_TEXT_VARIATION_PASSWORD);
                textFieldPassword.setTransformationMethod(b ? null : new PasswordTransformationMethod());
            }
        });
        // select open network by default
        ((RadioGroup)view.findViewById(R.id.radioGroupNetworkType)).check(R.id.radioButton1);

        return view;
    }


    public static View createInstanceWithNetworkTypeAndSSID(MainActivity mainActivity, int securityType, String ssid) {
        View view = createInstance(mainActivity);

        ((EditText)view.findViewById(R.id.textFieldSSID)).setText(ssid);
        view.findViewById(R.id.textFieldSSID).setEnabled(false);
        ((RadioGroup)view.findViewById(R.id.radioGroupNetworkType)).clearCheck();
        switch (securityType) {
            case 1:
                ((RadioGroup)view.findViewById(R.id.radioGroupNetworkType)).check(R.id.radioButton1);
                break;
            case 2:
                ((RadioGroup)view.findViewById(R.id.radioGroupNetworkType)).check(R.id.radioButton2);
                break;
            case 3:
                ((RadioGroup)view.findViewById(R.id.radioGroupNetworkType)).check(R.id.radioButton3);
                break;
            default:
                Log.e(MainActivity.LOG_TAG, "unknown securityType="+securityType);
        }
        view.findViewById(R.id.radioGroupNetworkType).setEnabled(false);
        view.findViewById(R.id.radioButton1).setEnabled(false);
        view.findViewById(R.id.radioButton2).setEnabled(false);
        view.findViewById(R.id.radioButton3).setEnabled(false);

        return view;
    }

}

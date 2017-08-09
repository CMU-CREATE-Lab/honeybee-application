package org.cmucreatelab.android.honeybee;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

public class MainActivity extends AppCompatActivity {

    private WebView webView;
    public static final String LOG_TAG = "Honeybee";


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
        webView.setWebViewClient(new CustomWebViewClient());
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

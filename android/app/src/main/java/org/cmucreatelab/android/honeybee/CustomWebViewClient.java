package org.cmucreatelab.android.honeybee;

import android.net.Uri;
import android.util.Log;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * Created by mike on 8/2/17.
 */

public class CustomWebViewClient extends WebViewClient {

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        Uri uri = Uri.parse(url);

        // if request is "schema://" then we override
        if (uri.getScheme().equals("schema")) {
            Log.i(MainActivity.LOG_TAG, "Caught message from browser: host=" + uri.getHost()+"\nPath=" + uri.getPath());
            view.loadUrl("javascript:alert(\"android\")");
            return true;
        }
        // otherwise, do not override
        return false;
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);
        Log.i(MainActivity.LOG_TAG, "Finished loading page URL="+url);
    }

}

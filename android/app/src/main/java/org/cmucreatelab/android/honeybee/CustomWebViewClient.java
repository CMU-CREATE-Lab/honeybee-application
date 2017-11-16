package org.cmucreatelab.android.honeybee;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * Created by mike on 8/2/17.
 *
 * A subclass of WebViewClient designed to override loading URLs with the custom schema "schema://".
 *
 */
public class CustomWebViewClient extends WebViewClient {

    private MainActivity mainActivity;


    public CustomWebViewClient(MainActivity mainActivity) {
        super();
        this.mainActivity = mainActivity;
    }


    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        Log.v(MainActivity.LOG_TAG, "shouldOverrideUrlLoading: "+url);
        Uri uri = Uri.parse(url);

        // if request is "schema://" then we override
        if (uri.getScheme().equals("schema")) {
            String host = uri.getHost();
            String path = uri.getEncodedPath().substring(1);
            Log.i(MainActivity.LOG_TAG, "Caught message from browser: host=" + host+"\nPath=/" + path);
            // NOTE: this ignores trailing slashes
            ApplicationInterface.parseSchema(GlobalHandler.getInstance(mainActivity), host, path.split("/"));
            return true;
        } else if (uri.getScheme().equals("http") || uri.getScheme().equals("https")) {
            Intent intent = new Intent(Intent.ACTION_VIEW,uri);
            mainActivity.startActivity(intent);
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

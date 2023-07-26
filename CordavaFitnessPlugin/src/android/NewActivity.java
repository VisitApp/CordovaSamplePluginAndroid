package info.android.activity;

import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class NewActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        String package_name = getApplication().getPackageName();
        int layout = getApplication().getResources().getIdentifier("activity_new", "layout", package_name);
        setContentView(layout);
        TextView textView = (TextView) findViewById(
                getApplication().getResources().getIdentifier("textView", "id", package_name));
        textView.setText("Chinmay");

        WebView webView = (WebView) findViewById(
                getApplication().getResources().getIdentifier("webView", "id", package_name));
        WebSettings settings = webView.getSettings();
        settings.setSupportMultipleWindows(true);
        settings.setJavaScriptCanOpenWindowsAutomatically(false);
        settings.setAllowFileAccessFromFileURLs(true);
        settings.setAllowUniversalAccessFromFileURLs(true);
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setCacheMode(2);
        webView.clearCache(true);
        webView.setBackgroundColor(0);
        webView.setLayerType(WebView.LAYER_TYPE_SOFTWARE, null);
        // webView.loadUrl("file:///android_asset/www/menu.html");
        webView.loadUrl("https://www.google.com/");
    }
}

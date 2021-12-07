package info.android.plugin.fitness;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;
import android.webkit.WebView;

import com.getvisitapp.google_fit.data.GoogleFitStatusListener;
import com.getvisitapp.google_fit.data.GoogleFitUtil;
import com.getvisitapp.google_fit.data.WebAppInterface;

import org.apache.cordova.BuildConfig;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import io.cordova.fitnessappcordova.R;


public class CordavaFitnessPlugin extends CordovaPlugin implements GoogleFitStatusListener {
    WebView mWebView;
    public static final String ACTIVITY_RECOGNITION = Manifest.permission.ACTIVITY_RECOGNITION;
    public static final int ACTIVITY_RECOGNITION_REQUEST_CODE = 490;
    GoogleFitUtil googleFitUtil;
    CallbackContext callbackContext;

    String TAG = "mytag";
    Activity activity;

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();

        Log.d(TAG, "plugin: pluginInitialize() calked");

        mWebView = (WebView) webView.getEngine().getView();
        mWebView.getSettings().setJavaScriptEnabled(true);
        activity = (Activity) this.cordova.getActivity();


    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if (action.equals("coolMethod")) {
            Log.d(TAG, "coolMethod() called");
            int arg1 = args.getInt(0);
            int arg2 = args.getInt(1);
            int result = arg1 + arg2;
            callbackContext.success("Result: " + result);
            return true;
        } else if (action.equals("connectToGoogleFit")) {

            Log.d(TAG, "plugin: connectToGoogleFit() called");

            if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                if (cordova.hasPermission(ACTIVITY_RECOGNITION)) {
                    googleFitUtil.askForGoogleFitPermission();
                } else {
                    cordova.requestPermissions(this, ACTIVITY_RECOGNITION_REQUEST_CODE, new String[]{ACTIVITY_RECOGNITION});
                }
            } else {
                googleFitUtil.askForGoogleFitPermission();
            }

            return true;

        } else if (action.equals("loadVisitWebUrl")) {
            String baseUrl = args.getString(0);
            String default_client_id = args.getString(1);
            String authToken = args.getString(2);
            String userId = args.getString(3);

            Log.d(TAG, "baseUrl: " + baseUrl);
            Log.d(TAG, "defaultClientID: " + default_client_id);
            Log.d(TAG, "token: " + authToken);
            Log.d(TAG, "userId: " + userId);

            String magicLink = baseUrl + "star-health?token=" + authToken + "&id=" + userId;

            Log.d("mytag", "magicLink: " + magicLink);
//            Uri magicUri = Uri.parse(magicLink);
//            Log.d("mytag", "magicUri: " + magicUri);

//            mWebView.setWebViewClient(new WebViewClient() {
//
//                @Override
//                public boolean shouldOverrideUrlLoading(WebView view, String url) {
//                    view.loadUrl(url);
//                    return true;
//                }
//            });
            // Load the webpage
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {

                    googleFitUtil = new GoogleFitUtil(activity, CordavaFitnessPlugin.this, default_client_id, baseUrl);
                    mWebView.addJavascriptInterface(googleFitUtil.getWebAppInterface(), "Android");
                    googleFitUtil.init();

//                    shouldOpenExternalUrl(magicLink);
                    // mWebView.loadUrl(magicLink);
                    webView.showWebPage(magicLink, false, false, new HashMap<>());

                }
            });
            return true;
        }
        return false;
    }

    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED) {
                //this.callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Permission Denied"));
                return;
            }
        }

        switch (requestCode) {
            case ACTIVITY_RECOGNITION_REQUEST_CODE:
                Log.d(TAG, "ACTIVITY_RECOGNITION_REQUEST_CODE permission granted");
                cordova.setActivityResultCallback(this);
                googleFitUtil.askForGoogleFitPermission();
                break;
        }
    }


    /**
     * This get called from the webview when user taps on [Connect To Google Fit]
     */

    @Override
    public void askForPermissions() {
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            cordova.requestPermissions(this, ACTIVITY_RECOGNITION_REQUEST_CODE, new String[]{ACTIVITY_RECOGNITION});
        } else {
            googleFitUtil.askForGoogleFitPermission();
        }
    }

    /**
     * 1A
     * This get called after user has granted all the fitness permission
     */
    @Override
    public void onFitnessPermissionGranted() {
        Log.d(TAG, "onFitnessPermissionGranted() called");
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                googleFitUtil.fetchDataFromFit();
            }
        });
    }

    /**
     * 1B
     * This is used to load the Daily Fitness Data into the Home Tab webView.
     */
    @Override
    public void loadWebUrl(String url) {
        Log.d("mytag", "daily Fitness Data url:" + url);
        webView.loadUrl(url);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        Log.d(TAG, "onActivityResult called. requestCode: " + requestCode + " resultCode: " + resultCode);

        super.onActivityResult(requestCode, resultCode, intent);

        if (requestCode == 4097 || requestCode == 1900) {
            cordova.setActivityResultCallback(this);
            googleFitUtil.onActivityResult(requestCode, resultCode, intent);

        }


    }


    /**
     * 2A
     * This get used for requesting data that are to be shown in detailed graph
     */

    @Override
    public void requestActivityData(String type, String frequency, long timestamp) {
        Log.d(TAG, "requestActivityData() called.");
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (type != null && frequency != null) {
                    googleFitUtil.getActivityData(type, frequency, timestamp);
                }
            }
        });
    }

    /**
     * 2B
     * This get called when google fit return the detailed graph data that was requested previously
     */

    @Override
    public void loadGraphDataUrl(String url) {
        mWebView.evaluateJavascript(
                url,
                null
        );
    }

    @Override
    public void syncDataWithServer(String baseUrl, String authToken, long googleFitLastSync, long gfHourlyLastSync) {

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                googleFitUtil.sendDataToServer(baseUrl + "/", authToken, googleFitLastSync, gfHourlyLastSync);
            }
        });
    }


}


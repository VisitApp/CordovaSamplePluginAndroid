package info.plugin;

import android.content.Intent;
import android.util.Log;

import com.getvisitapp.google_fit.CordovaFitnessActivity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONException;

/**
 * This class echoes a string called from JavaScript.
 */
public class CordovaFitnessPlugin extends CordovaPlugin {

    protected static final String TAG = "mytag";

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();
        Log.d(TAG, "plugin: pluginInitialize() called");

    }

    /**
     * Executes the request and returns PluginResult.
     *
     * @param action          the action to execute.
     * @param args            JSONArry of arguments for the plugin.
     * @param callbackContext the callbackContext used when calling back into
     *                        JavaScript.
     * @return A PluginResult object with a status and message.
     */
    public boolean execute(String action, CordovaArgs args, final CallbackContext callbackContext)
            throws JSONException {

        if (action.equals("open")) {
            String magicLink = args.getString(0);
            String default_client_id = args.getString(1);

            Log.d(TAG, "magicLink: " + magicLink);
            Log.d(TAG, "default_client_id: " + default_client_id);

            Intent intent = new Intent(cordova.getActivity(), CordovaFitnessActivity.class);
            intent.putExtra("ssoLink", magicLink);
            intent.putExtra("default_client_id", default_client_id);
            if (this.cordova != null) {
                this.cordova.startActivityForResult((CordovaPlugin) this, intent, 0);
            }

        }
        return true;
    }

}
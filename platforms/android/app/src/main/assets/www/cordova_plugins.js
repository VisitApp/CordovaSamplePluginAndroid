cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "cordova-plugin-splashscreen.SplashScreen",
      "file": "plugins/cordova-plugin-splashscreen/www/splashscreen.js",
      "pluginId": "cordova-plugin-splashscreen",
      "clobbers": [
        "navigator.splashscreen"
      ]
    },
    {
      "id": "cordova-plugin-statusbar.statusbar",
      "file": "plugins/cordova-plugin-statusbar/www/statusbar.js",
      "pluginId": "cordova-plugin-statusbar",
      "clobbers": [
        "window.StatusBar"
      ]
    },
    {
      "id": "com.mwj.cordova.androidvideoplayer.AndroidVideoPlayer",
      "file": "plugins/com.mwj.cordova.androidvideoplayer/www/androidvideoplayer.js",
      "pluginId": "com.mwj.cordova.androidvideoplayer",
      "clobbers": [
        "AndroidVideoPlayer"
      ]
    },
    {
      "id": "info.android.plugin.fitness.CordavaFitnessPlugin",
      "file": "plugins/info.android.plugin.fitness/www/CordavaFitnessPlugin.js",
      "pluginId": "info.android.plugin.fitness",
      "clobbers": [
        "cordova.plugins.CordavaFitnessPlugin"
      ]
    }
  ];
  module.exports.metadata = {
    "cordova-plugin-splashscreen": "6.0.0",
    "cordova-plugin-statusbar": "3.0.0",
    "com.mwj.cordova.androidvideoplayer": "1.0.3",
    "info.android.plugin.fitness": "1.0.0"
  };
});
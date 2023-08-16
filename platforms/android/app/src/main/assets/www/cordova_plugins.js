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
      "id": "info.plugin.fitness.CordovaFitnessPlugin",
      "file": "plugins/info.plugin.fitness/www/CordovaFitnessPlugin.js",
      "pluginId": "info.plugin.fitness",
      "clobbers": [
        "cordova.plugins.CordovaFitnessPlugin"
      ]
    }
  ];
  module.exports.metadata = {
    "cordova-plugin-splashscreen": "6.0.0",
    "cordova-plugin-statusbar": "3.0.0",
    "info.plugin.fitness": "1.0.0"
  };
});
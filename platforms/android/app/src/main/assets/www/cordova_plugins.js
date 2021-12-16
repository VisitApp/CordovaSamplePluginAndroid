cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "info.android.plugin.fitness.CordavaFitnessPlugin",
      "file": "plugins/info.android.plugin.fitness/www/CordavaFitnessPlugin.js",
      "pluginId": "info.android.plugin.fitness",
      "clobbers": [
        "cordova.plugins.CordavaFitnessPlugin"
      ]
    },
    {
      "id": "cordova-plugin-statusbar.statusbar",
      "file": "plugins/cordova-plugin-statusbar/www/statusbar.js",
      "pluginId": "cordova-plugin-statusbar",
      "clobbers": [
        "window.StatusBar"
      ]
    }
  ];
  module.exports.metadata = {
    "cordova-plugin-whitelist": "1.3.5",
    "info.android.plugin.fitness": "1.0.0",
    "cordova-plugin-statusbar": "3.0.0"
  };
});
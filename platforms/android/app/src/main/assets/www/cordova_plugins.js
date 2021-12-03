cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
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
    "cordova-plugin-whitelist": "1.3.5",
    "info.android.plugin.fitness": "1.0.0"
  };
});
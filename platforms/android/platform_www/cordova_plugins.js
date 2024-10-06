cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
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
    "info.plugin.fitness": "1.0.0"
  };
});
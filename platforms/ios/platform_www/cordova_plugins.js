cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "info.plugin.fitness.CordavaFitnessPlugin",
      "file": "plugins/info.plugin.fitness/www/CordavaFitnessPlugin.js",
      "pluginId": "info.plugin.fitness",
      "clobbers": [
        "cordova.plugins.CordavaFitnessPlugin"
      ]
    }
  ];
  module.exports.metadata = {
    "info.plugin.fitness": "1.0.0"
  };
});
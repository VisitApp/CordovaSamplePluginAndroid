var exec = require("cordova/exec");

exports.coolMethod = function (arg0, success, error) {
  exec(success, error, "CordavaFitnessPlugin", "coolMethod", [arg0]);
};

function plugin() {}

plugin.prototype.new_activity = function () {
  exec(
    function (res) {},
    function (err) {},
    "PluginName",
    "new_activity",
    []
  );
};

module.exports = new plugin();

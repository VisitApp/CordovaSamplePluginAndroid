cordova.define("info.android.plugin.fitness.CordavaFitnessPlugin", function(require, exports, module) {
var exec = require("cordova/exec");

exports.coolMethod = function (arg0, success, error) {
  exec(success, error, "CordavaFitnessPlugin", "coolMethod", [arg0]);
};

});

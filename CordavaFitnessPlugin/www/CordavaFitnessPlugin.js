var exec = require("cordova/exec");

var CordavaFitnessPlugin = function () {}; // This just makes it easier for us to export all of the functions at once.
// All of your plugin functions go below this.
// Note: We are not passing any options in the [] block for this, so make sure you include the empty [] block.

CordavaFitnessPlugin.addTwoNumber = function (arg0, onSuccess, onError) {
  exec(onSuccess, onError, "CordavaFitnessPlugin", "coolMethod", arg0);
};

CordavaFitnessPlugin.new_activity = function (arg0, onSuccess, onError) {
  exec(onSuccess, onError, "CordavaFitnessPlugin", "new_activity", arg0);
};

CordavaFitnessPlugin.loadVisitWebUrl = function (arg0, onSuccess, onError) {
  exec(onSuccess, onError, "CordavaFitnessPlugin", "loadVisitWebUrl", arg0);
};

module.exports = CordavaFitnessPlugin;

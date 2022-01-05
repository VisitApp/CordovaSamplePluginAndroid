// Wait for the deviceready event before using any of Cordova's device APIs.
// See https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready
document.addEventListener("deviceready", onDeviceReady, false);

function onDeviceReady() {
  // Cordova is now initialized. Have fun!

  console.log("Running cordova-" + cordova.platformId + "@" + cordova.version);
  document.getElementById("deviceready").classList.add("ready");

  document
    .getElementById("loadVisitApp")
    .addEventListener("click", function () {
      loadVisitURL(
        "https://star-health.getvisitapp.xyz/",
        "967914547335-g2ntga70t1i7b19ti91gcubb7agm7rje.apps.googleusercontent.com",
        "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOi[%E2%80%A6]GFsIn0.f0656mzmcRMSCywkbEptdd6JgkDfIqN0S9t-P1aPyt8",
        "8158"
      );
    });
}

function loadVisitURL(baseUrl, firebase_default_client_id, user_token, userId) {
  //  console.log("loadVisitURL called");

  cordova.exec(
    success,
    null,
    "CordavaFitnessPlugin", //plugin class name
    "loadVisitWebUrl", //plugin method
    [
      baseUrl, //base url (should change based on the build type)
      firebase_default_client_id, //firebase default_client_id (should change based on the build type)
      user_token, //token
      userId,
    ] //userId
  );
}

function success(result){
    console.log("Close the app"+result);
    alert(result);
};

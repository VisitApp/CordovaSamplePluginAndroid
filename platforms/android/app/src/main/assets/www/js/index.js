

// Wait for the deviceready event before using any of Cordova's device APIs.
// See https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {
    // Cordova is now initialized. Have fun!

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');



    document.getElementById('loadVisitApp').addEventListener('click',loadVisitURL);
}



function loadVisitURL(){
    //console.log("loadVisitURL called");

    cordova.exec(null,
    null,
    "CordavaFitnessPlugin", //plugin class name
    "loadVisitWebUrl", //plugin method
    ["https://star-health.getvisitapp.xyz/", //base url (should change based on the build type)
    "967914547335-g2ntga70t1i7b19ti91gcubb7agm7rje.apps.googleusercontent.com", //firebase default_client_id (should change based on the build type)
    "Bearer%20eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOi[%E2%80%A6]GFsIn0.f0656mzmcRMSCywkbEptdd6JgkDfIqN0S9t-P1aPyt8", //token
    "8158"] //userId
   );
}

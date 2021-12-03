

// Wait for the deviceready event before using any of Cordova's device APIs.
// See https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {
    // Cordova is now initialized. Have fun!

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');

    setTimeout(function(){
        cordova.exec(success,null,"CordovaFitnessPlugin","coolMethod",[111,222]);
    },5000);

    document.getElementById('loadVisitApp').addEventListener('click',loadVisitURL);

}

function success(result){
    alert(result);
}


function loadVisitURL(){
    console.log("loadVisitURL called");
    cordova.exec(null,
    null,
    "CordavaFitnessPlugin",
    "loadVisitWebUrl",
    ["https://web.getvisitapp.xyz/","967914547335-g2ntga70t1i7b19ti91gcubb7agm7rje.apps.googleusercontent.com"]
   );
}

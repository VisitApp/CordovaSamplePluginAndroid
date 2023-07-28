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
      console.log("loadVisitApp called");

      loadVisitURL(
        "https://star-health.getvisitapp.xyz/",
        "967914547335-g2ntga70t1i7b19ti91gcubb7agm7rje.apps.googleusercontent.com",
        "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOi[%E2%80%A6]GFsIn0.f0656mzmcRMSCywkbEptdd6JgkDfIqN0S9t-P1aPyt8",
        "8158",
        "https://itgi.getvisitapp.xyz/sso?userParams=-PVcv_tShE-luebNROediKFWXRcMIp0qicT-aHR3-oWBmEPIMk2bfepPVz1-qUluOIzuIq1zzeAnsGYw9WQ_QkhYQYYmBIbiHAcG_823wJ-4CApPZSkVZjo4Mb7KVT-fMEO4_IhDwSrL5_f7JhRzLA3-TNPrxj9FerxlSo6GZxpjNci9_KWnFUwIuMTBXZOxONEKO7ipCKMtzh90JJgbUcPkT4q-R140V8LFpO5YbNtZSBiI-8uAy2VIWMX4tl9VDBP72XYKx0GSwgFkEghXXML-IESpW5Hd8saQ_KJm65MIO-6EWAerRbQQX4DZauhqOyUvkFKDAUtpS6zDjRwudw&clientId=itgi-sdk-012"
      );
    });

  document
    .getElementById("openNewActivity")
    .addEventListener("click", function () {
      console.log("openNewActivity called");

      openNewActivity();
    });

  document
    .getElementById("openInAppBrowser")
    .addEventListener("click", function () {
      console.log("openInAppBrowser called");

      openInAppBrowser();
    });

  document.getElementById("playVideo").addEventListener("click", function () {
    console.log("playVideo called");

    playVideo();
  });
}

function loadVisitURL(
  baseUrl,
  firebase_default_client_id,
  user_token,
  userId,
  directMagicLink
) {
  //  console.log("loadVisitURL called");

  cordova.exec(
    function (winParam) {
      console.log(winParam);
    },
    function (error) {
      console.log(error);
    },
    "CordavaFitnessPlugin", //plugin class name
    "loadVisitWebUrl", //plugin method
    [
      baseUrl, //base url (should change based on the build type)
      firebase_default_client_id, //firebase default_client_id (should change based on the build type)
      user_token, //token
      userId,
      directMagicLink,
    ] //userId
  );
}

function openNewActivity() {
  //  console.log("loadVisitURL called");

  cordova.exec(
    function (winParam) {
      console.log(winParam);
    },
    function (error) {
      console.log(error);
    },
    "CordavaFitnessPlugin", //plugin class name
    "new_activity", //plugin method
    []
  );
}

function openInAppBrowser() {
  let url =
    "https://itgi.getvisitapp.xyz/sso?userParams=-PVcv_tShE-luebNROediKFWXRcMIp0qicT-aHR3-oWBmEPIMk2bfepPVz1-qUluOIzuIq1zzeAnsGYw9WQ_QkhYQYYmBIbiHAcG_823wJ-4CApPZSkVZjo4Mb7KVT-fMEO4_IhDwSrL5_f7JhRzLA3-TNPrxj9FerxlSo6GZxpjNci9_KWnFUwIuMTBXZOxONEKO7ipCKMtzh90JJgbUcPkT4q-R140V8LFpO5YbNtZSBiI-8uAy2VIWMX4tl9VDBP72XYKx0GSwgFkEghXXML-IESpW5Hd8saQ_KJm65MIO-6EWAerRbQQX4DZauhqOyUvkFKDAUtpS6zDjRwudw&clientId=itgi-sdk-012";
  let ref = cordova.InAppBrowser.open(
    url,
    "_blank",
    "location=no,hidden=no,hidenavigationbuttons=no,hardwareback=yes,fullscreen=yes"
  );

  // setTimeout(function () {
  //   ref.close();
  // }, 5000);
}

function playVideo() {
  // cordova.VideoPlayer.play(
  //   "https://www.youtube.com/watch?v=a3ICNMQW7Ok&ab_channel=TimotiusJoso",
  //   {
  //     volume: 0.5,
  //     scalingMode: VideoPlayer.SCALING_MODE.SCALE_TO_FIT_WITH_CROPPING,
  //     cancelableDialog: true,
  //   },
  //   function () {
  //     console.log("video completed");
  //   },
  //   function (err) {
  //     console.log(err);
  //   }
  // );
  // cordova.VideoPlayer.play(
  //   "https://samplelib.com/lib/preview/mp4/sample-5s.mp4",
  //   {
  //     volume: 0.5,
  //     scalingMode: VideoPlayer.SCALING_MODE.SCALE_TO_FIT_WITH_CROPPING,
  //     cancelableDialog: true,
  //   },
  //   function () {
  //     console.log("video completed");
  //   },
  //   function (err) {
  //     console.log(err);
  //   }
  // );
  // cordova.exec(
  //   function (winParam) {
  //     console.log(winParam);
  //   },
  //   function (error) {
  //     console.log(error);
  //   },
  //   "AndroidVideoPlayer", //plugin class name
  //   "play", //plugin method
  //   ["https://samplelib.com/lib/preview/mp4/sample-5s.mp4"]
  // );
}

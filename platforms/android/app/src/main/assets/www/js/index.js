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
        "https://star-health.getvisitapp.xyz/?mluib7c=BXQqShdC",
        "967914547335-g2ntga70t1i7b19ti91gcubb7agm7rje.apps.googleusercontent.com"
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

function loadVisitURL(directMagicLink, firebase_default_client_id) {
  //  console.log("loadVisitURL called");

  cordova.exec(
    function (winParam) {
      console.log(winParam);
    },
    function (error) {
      console.log(error);
    },
    "CordavaFitnessPlugin", //plugin class name
    "open", //plugin method
    [
      directMagicLink,
      firebase_default_client_id, //firebase default_client_id (should change based on the build type)
    ]
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
  let url = "https://star-health.getvisitapp.xyz/?mluib7c=BXQqShdC";
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

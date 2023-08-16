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
        "https://itgi.getvisitapp.xyz/sso?userParams=kdRDkaQXGejyMZrFaX%2FMraWZoXzqXQr3u6HEsC%2BMuX4OOZSjH%2BKOYbC9NKcQTKVkboq2QhRpDLq4LxhpJC%2Frr4%2Bo5rQojgwC7JzKIR4MJr6mrF%2BKxwSm2jG7HrPRod7Z%2Bya8DCcyz%2F18aMfFxX7bWfH7uXKds3E%2FExtEMcZAJhKqIJ%2FUypD0zPbRn1IlgHJIqXDBYYOLb5pHe1Pn85LQ2TOEj8UE5zrJzNIxbZFs0e8xVarmQYnKrDUWH%2BmaZ4dQr1hLzhqk0svtJhJifvzvjdwWisgQz8QJ%2Bv7hAmALQdZhWKlu%2FWAwz1XS7peecPc4E9T8y2ZwwhQJeBoZ4YS7dI4xcigz6U8t&clientId=itgi-sdk-012",
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
  console.log("loadVisitURL called");

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

  // let url = "https://star-health.getvisitapp.xyz/?mluib7c=BXQqShdC";
  // let ref = cordova.InAppBrowser.open(
  //   url,
  //   "_blank",
  //   "location=no,hidden=no,hidenavigationbuttons=no,hardwareback=yes,fullscreen=yes"
  // );
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

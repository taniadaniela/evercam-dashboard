/**
 * Created by evercam on 4/6/15.
 */
var SaveImage = (function() {
  "use strict";

  var that = {};

  that.init = function() {

  };


    function isNativeApp(){
        return /io.evercam.androidapp\/[0-9\.]+$/.test(navigator.userAgent);
    }

  that.save = function (fileURL, fileName) {
    var hyperlink = document.createElement('a');
    hyperlink.href = fileURL;
    console.log(fileURL);
    hyperlink.target = '_blank';
    hyperlink.download = fileName || fileURL;

    (document.body || document.documentElement).appendChild(hyperlink);
    hyperlink.onclick = function() {
       (document.body || document.documentElement).removeChild(hyperlink);
    };

    var mouseEvent = new MouseEvent('click', {
        view: window,
        bubbles: true,
        cancelable: true
    });

    hyperlink.dispatchEvent(mouseEvent);

    // NEVER use "revoeObjectURL" here
    // you can use it inside "onclick" handler, though.
    // (window.URL || window.webkitURL).revokeObjectURL(hyperlink.href);

    // if you're writing cross-browser function:
    if(!navigator.mozGetUserMedia) { // i.e. if it is NOT Firefox
       window.URL.revokeObjectURL(hyperlink.href);
    }

  };

  return that;
}());

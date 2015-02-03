(function(window) {

  "use strict";
// Localize jQuery variable
  var jQuery,
    url = '<%= EVERCAM_API %>cameras/<%= params[:camera] %>/live/snapshot',
    container,
    refresh = 1000*<%= params[:refresh] %>,
    priv = <%= params[:private] %>;

  function updateImage() {
    if (refresh > 0) {
      window.ec_watcher = setTimeout(updateImage, refresh);
    }
    jQuery("<img style='width: 100%;'/>").attr('src', url + '?' + new Date().getTime())
      .load(function() {
        if (!this.complete || this.naturalWidth === undefined || this.naturalWidth === 0) {
          console.log('broken image!');
        } else {
          container.empty().append(jQuery(this))
          console.log('updated');
        }
      });
  }

  function handleVisibilityChange() {
    if (document.hidden) {
      clearTimeout(window.ec_watcher);
      console.log('stop');
    } else  {
      updateImage();
      console.log('start');
    }
  }

  /******** Our main function ********/
  function main() {
    jQuery(document).ready(function($) {
      /******* Load HTML *******/
      container = $('#ec-container');
      if (priv) {
        var window_height = $(window).height();
        container.html('<iframe id="ec-frame" style="width: 100%;min-height:' + window_height + 'px; height:100%;" src="<%= request.base_url %>/live.view.private.widget?camera=<%= params[:camera] %>&refresh=<%= params[:refresh] %>&api_id=<%= params[:api_id] %>&api_key=<%= params[:api_key] %>" frameborder="0" scrolling="no"/>');
        $('#ec-frame').load(function() {
          console.log($('#ec-frame').attr('src'));
        });
      } else {
        container.html("<img/>");
        updateImage();
        window.ec_vis_handler = handleVisibilityChange;
        document.addEventListener("visibilitychange", handleVisibilityChange, false);
      }
    });
  }

  /******** Called once jQuery has loaded ******/
  function scriptLoadHandler() {
    // Restore $ and window.jQuery to their previous values and store the
    // new jQuery in our local jQuery variable
    jQuery = window.jQuery.noConflict(true);
    // Call our main function
    main();
  }

  /******** Load jQuery if not present *********/
  if (window.jQuery === undefined || window.jQuery.fn.jquery !== '2.1.1') {
    var script_tag = document.createElement('script');
    script_tag.setAttribute("type","text/javascript");
    script_tag.setAttribute("src",
      "https://code.jquery.com/jquery-2.1.1.min.js");
    if (script_tag.readyState) {
      script_tag.onreadystatechange = function () { // For old versions of IE
        if (this.readyState === 'complete' || this.readyState === 'loaded') {
          scriptLoadHandler();
        }
      };
    } else {
      script_tag.onload = scriptLoadHandler;
    }
    // Try to find the head, otherwise default to the documentElement
    (document.getElementsByTagName("head")[0] || document.documentElement).appendChild(script_tag);
  } else {
    // The jQuery version on the window is the one we want to use
    jQuery = window.jQuery;
    main();
  }

}(window));

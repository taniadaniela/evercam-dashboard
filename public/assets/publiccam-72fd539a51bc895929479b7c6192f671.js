(function(){var a,e,r,t;r=function(a){return Notification.show(a),!0},t=function(a){return Notification.show(a),!0},e=function(a){var e,i,n,c,o,u;return a.preventDefault(),n=$(a.target),i=n.attr("email"),e=n.attr("camera_id"),u="minimal",c=function(){return r("Add camera to my shared cameras failed."),!1},o=function(a){return a.success?t("Successfully added to your shared cameras."):r("Camera has already been added to your shared cameras."),!0},window.Evercam.Share.createShare(e,i,u,o,c),!0},a=function(){return $(".create-share-button").click(e),Notification.init(".bb-alert"),!0},window.Evercam||(window.Evercam={}),window.Evercam.Publiccam={initialize:a}}).call(this);
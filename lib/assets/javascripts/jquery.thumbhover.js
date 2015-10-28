(function ($) {
    $.fn.thumbPopup = function (options) {
        //Combine the passed in options with the default settings
        settings = jQuery.extend({
            popupId: "thumbPopup",
            popupCSS: { 'border': '1px solid #000000', 'background': '#FFFFFF' },
            imgSmallFlag: "_t",
            imgLargeFlag: "_l",
            cursorTopOffset: 15,
            cursorLeftOffset: 15,
            loadingHtml: ""
        }, options);
        //<span style='padding: 5px;'>Loading</span>
        //Create our popup element
        popup =
		$("<div />")
		.css(settings.popupCSS)
		.attr("id", settings.popupId)
		.css({ "position": "absolute", "z-index": "999" })
		.appendTo("body").hide();

        //Attach hover events that manage the popup     .hover .mouseover(updatePopupPosition)
        $(this)
        .hover(setPopup)
		.mousemove(updatePopupPosition)
		.mouseout(hidePopup);

        function setPopup(event) {
            var fullImgURL = $(this).attr("src").replace(settings.imgSmallFlag, settings.imgLargeFlag);

            $(this).data("hovered", true);
            var pagey = 480;
            if ((event.pageY - 15) < 480)
                pagey = event.pageY - 15;
            //Load full image in popup
            $("<img />")
			.bind("load", { thumbImage: this }, function (event) {
			    //Only display the larger image if the thumbnail is still being hovered
			    if ($(event.data.thumbImage).data("hovered") == true) {
			        $(popup).empty().append(this);
			        //updatePopupPosition(event);
			        $(popup).show();
			    }
			    $(event.data.thumbImage).data("cached", true);
			})
			.height(213) //pagey
            .width(284)
			.attr("src", fullImgURL);

            //If no image has been loaded yet then place a loading message
            if ($(this).data("cached") != true) {
                $(popup).append($(settings.loadingHtml));
                $(popup).show();
            }
            if ($(popup).width() != 0 && $(popup).height() != 0)
                updatePopupPosition(event);
        }

        function updatePopupPosition(event) {
            var windowSize = getWindowSize();
            var popupSize = getPopupSize();

            popupSize.width = 284;
            popupSize.height = 213;
            //event.pageX - popupSize.width - settings.cursorLeftOffset);
            $(popup).css("top", event.pageY - 210); //event.pageY - popupSize.height - settings.cursorTopOffset);
            if (event.pageX > popupSize.width + 185)
                $(popup).css("left", event.pageX - 290);
            else
                $(popup).css("left", event.pageX + 10);

            //console.log(windowSize.scrollLeft + '-----' + event.pageX);
            //console.log(windowSize.scrollTop + '-----' + event.pageY);
            /*
            if (popupSize.width < 640 && popupSize.height < 480) {
            popupSize.width = 640;
            popupSize.height = 480;
            }
            if (windowSize.width + windowSize.scrollLeft < event.pageX + popupSize.width + settings.cursorLeftOffset) {
            if (popupSize.width > 700)
            $(popup).css("left", 5);
            else
            $(popup).css("left", event.pageX - popupSize.width - settings.cursorLeftOffset);
            } else {
            if (popupSize.width > 700)
            $(popup).css("left", 5);
            else
            $(popup).css("left", event.pageX + settings.cursorLeftOffset);
            }
            if (windowSize.height + windowSize.scrollTop < event.pageY + popupSize.height + settings.cursorTopOffset) {
            if (event.pageY - popupSize.height - settings.cursorTopOffset < windowSize.scrollTop) {
            var diff = windowSize.scrollTop - (event.pageY - popupSize.height - settings.cursorTopOffset);
            $(popup).css("top", event.pageY - popupSize.height - settings.cursorTopOffset + diff + 5);
            }
            else {
            $(popup).css("top", event.pageY - popupSize.height - settings.cursorTopOffset);
            }
            } else {
            $(popup).css("top", event.pageY + settings.cursorTopOffset);
            }*/
        }

        function hidePopup(event) {
            $(this).data("hovered", false);
            $(popup).empty().hide();
            $("#thumbPopup").hide();
        }

        function getWindowSize() {
            return {
                scrollLeft: $(window).scrollLeft(),
                scrollTop: $(window).scrollTop(),
                width: $(window).width(),
                height: $(window).height()
            };
        }

        function getPopupSize() {
            return {
                width: $(popup).width(),
                height: $(popup).height()
            };
        }

        //Return original selection for chaining
        return this;
    };
})(jQuery);
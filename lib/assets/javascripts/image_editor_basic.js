/**
 * basic.js
 * @author NHN Ent. FE Development Team <dl_javascript@nhnent.com>
 * @fileoverview
 */
'use strict';

 function ChangeUrl(title, url) {
   if (typeof (history.pushState) != "undefined") {
       var obj = { Title: title, Url: url };
       history.pushState(obj, obj.Title, obj.Url);
   } else {
       alert("Browser does not support HTML5.");
   }
}

function copyUrl(){
  var url = document.createElement('p');
	url.innerHTML = "https://project1-evercam.herokuapp.com/image-editor/img/img.html";

	var div1 = document.createElement('div');
	div1.contentEditable = true;
	div1.appendChild(url);
	document.body.appendChild(div1);

	SelectText(div1);
	try {
		var successful = document.execCommand('copy');
		var msg = successful ? 'successful' : 'unsuccessful';
		console.log('Copying text command was ' + msg);
	  } catch (err) {
		console.log('Oops, unable to copy');
	}
	document.body.removeChild(div1);
}

function copyImg(){
  var img = document.createElement('img');
	img.src = imageEditor.toDataURL('image/jpeg', 0.1);

	var div1 = document.createElement('div');
	div1.contentEditable = true;
	div1.appendChild(img);
	document.body.appendChild(div1);

	SelectText(div1);
	try {
		var successful = document.execCommand('copy');
		var msg = successful ? 'successful' : 'unsuccessful';
		console.log('Copying text command was ' + msg);
	  } catch (err) {
		console.log('Oops, unable to copy');
	}
	document.body.removeChild(div1);
}

function SelectText(element) {
	var doc = document;
	if (doc.body.createTextRange) {
		var range = document.body.createTextRange();
		range.moveToElementText(element);
		range.select();
	} else if (window.getSelection) {
		var selection = window.getSelection();
		var range = document.createRange();
		range.selectNodeContents(element);
		selection.removeAllRanges();
		selection.addRange(range);
	}
}

var supportingFileAPI = !!(window.File && window.FileList && window.FileReader);
var rImageType = /data:(image\/.+);base64,/;
var shapeOptions = {};
var image_title, shapeType, activeObjectId, imageEditor, instanceBrush, instanceText, instanceShape, instanceArrow;

// Buttons
var $btns, $btnsActivatable, $inputImage, $btnDownload, $btnUndo, $btnRedo, $btnClearObjects, $btnDrawLinefree, $btnDrawLinestraight, $btnDrawRect;
var $btnDrawCircle, $btnSelection, $btnText, $btnAddIcon, $btnRegisterIcon, $btnClose;

// Input etc.
var $inputBrushWidthRange, $inputFontSizeRange, $inputStrokeWidthRange, $inputCheckTransparent, $inputCheckGrayscale;

// Sub menus
var $displayingSubMenu, $freeDrawingSubMenu, $drawLineSubMenu, $drawShapeSubMenu, $textSubMenu, $iconSubMenu, $filterSubMenu, $imageFilterSubMenu;

// Select line type
var $selectLine, $selectShapeType, $drawRectangle, $selectColorType, $selectBlendType;

function set_variables() {
  //buttons
  $btns = $('.menu-item');
  $btnsActivatable = $btns.filter('.activatable');
  $inputImage = $('#input-image-file');
  $btnDownload = $('#btn-download');
  $btnUndo = $('#btn-undo');
  $btnRedo = $('#btn-redo');
  $btnClearObjects = $('#btn-clear-objects');
  $btnDrawLinefree = $('#btn-draw-line-free');
  $btnDrawLinestraight = $('#btn-draw-line-straight');
  $btnDrawRect = $('#btn-draw-rect');
  $btnDrawCircle = $('#btn-draw-circle');
  $btnSelection = $('#selection');
  $btnText = $('#btn-text');
  $btnAddIcon = $('#btn-add-icon');
  $btnRegisterIcon = $('#btn-register-icon');
  $btnClose = $('.close');

  //input
  $inputBrushWidthRange = $('#input-brush-width-range');
  $inputFontSizeRange = $('#input-font-size-range');
  $inputStrokeWidthRange = $('#input-stroke-width-range');
  $inputCheckTransparent = $('#input-check-transparent');
  $inputCheckGrayscale = $('#input-check-grayscale');

  // Sub menus
  $displayingSubMenu = $();
  $freeDrawingSubMenu = $('#free-drawing-sub-menu');
  $drawLineSubMenu = $('#draw-line-sub-menu');
  $drawShapeSubMenu = $('#draw-shape-sub-menu');
  $textSubMenu = $('#text-sub-menu');
  $iconSubMenu = $('#icon-sub-menu');
  $filterSubMenu = $('#filter-sub-menu');
  $imageFilterSubMenu = $('#image-filter-sub-menu');

  // Select line type
  $selectLine = $('[name="select-line-type"]');

  // Select shape type
  $selectShapeType = $('[name="select-shape-type"]');
  $drawRectangle = $('#type-rectangle');

  // Select color of shape type
  $selectColorType = $('[name="select-color-type"]');

  //Select blend type
  $selectBlendType = $('[name="select-blend-type"]');
}

function initImageEditor() {
  var view_height = Metronic.getViewPort().height;
  var view_width = Metronic.getViewPort().width;
  var side_bar_width = $(".page-sidebar").width();
  var controls_height = $(".tui-image-editor-controls").height();
  var nav_tab = $("#ul-nav-tab").height();
  var top_height = controls_height + nav_tab;
  view_height = view_height - top_height;

  if($(".page-sidebar").css('display') == "none") {
    view_width = view_width - side_bar_width;
  }

  imageEditor = new tui.ImageEditor(document.querySelector('#tui-image-editor'), {
      // cssMaxWidth: view_width,
      // cssMaxHeight: view_height,
      usageStatistics: false,
      selectionStyle: {
        cornerSize: 20,
        rotatingPointOffset: 70
      }
  });
  // $(".tui-image-editor-canvas-container").css("top", top_height)
}

function initColorPicker() {
  instanceBrush = tui.colorPicker.create({
  	container: $('#tui-brush-color-picker')[0],
    color: '#000000'
  });

  instanceText = tui.colorPicker.create({
  	container: $('#tui-text-color-picker')[0],
    color: '#000000'
  });

  instanceShape = tui.colorPicker.create({
  	container: $('#tui-shape-color-picker')[0],
    color: '#000000'
  });

  instanceArrow = tui.colorPicker.create({
    container: $('#tui-arrow-color-picker')[0],
    color: '#000000'
  });
}

// Common global functions
// HEX to RGBA
function hexToRGBa(hex, alpha) {
    var r = parseInt(hex.slice(1, 3), 16);
    var g = parseInt(hex.slice(3, 5), 16);
    var b = parseInt(hex.slice(5, 7), 16);
    var a = alpha || 1;

    return 'rgba(' + r + ', ' + g + ', ' + b + ', ' + a + ')';
}

function base64ToBlob(data) {
    var mimeString = '';
    var raw, uInt8Array, i, rawLength;

    raw = data.replace(rImageType, function(header, imageType) {
        mimeString = imageType;

        return '';
    });

    raw = atob(raw);
    rawLength = raw.length;
    uInt8Array = new Uint8Array(rawLength); // eslint-disable-line

    for (i = 0; i < rawLength; i += 1) {
        uInt8Array[i] = raw.charCodeAt(i);
    }

    return new Blob([uInt8Array], {type: mimeString});
}

function setShapeToolbar(obj) {
    var strokeColor, fillColor, isTransparent;
    var colorType = $selectColorType.val();

    if (colorType === 'stroke') {
        strokeColor = obj.stroke;
        isTransparent = (strokeColor === 'transparent');

        if (!isTransparent) {
            shapeColorpicker.setColor(strokeColor);
        }
    } else if (colorType === 'fill') {
        fillColor = obj.fill;
        isTransparent = (fillColor === 'transparent');

        if (!isTransparent) {
            shapeColorpicker.setColor(fillColor);
        }
    }

    $inputCheckTransparent.prop('checked', isTransparent);
    $inputStrokeWidthRange.val(obj.strokeWidth);
}

function resizeEditor() {
    var $editor = $('.tui-image-editor');
    var $container = $('.tui-image-editor-canvas-container');
    var height = parseFloat($container.css('max-height'));

    $editor.height(height);
}

function getBrushSettings() {
    var brushWidth = 10;//
    var brushColor = instanceBrush.getColor();

    return {
        width: brushWidth,
        color: hexToRGBa(brushColor, 1.0)
    };
}

function activateShapeMode() {
    if (imageEditor.getDrawingMode() !== 'SHAPE') {
        imageEditor.stopDrawingMode();
        imageEditor.startDrawingMode('SHAPE');
    }
}

function activateSelectionMode() {
    imageEditor.stopDrawingMode();
}

function activateIconMode() {
    imageEditor.stopDrawingMode();
}

function activateTextMode() {
    if (imageEditor.getDrawingMode() !== 'TEXT') {
        imageEditor.stopDrawingMode();
        imageEditor.startDrawingMode('TEXT');
    }
}

function setTextToolbar(obj) {
    var fontSize = obj.fontSize;
    var fontColor = obj.fill;

    $inputFontSizeRange.val(fontSize);
    instanceText.setColor(fontColor);
}

function setIconToolbar(obj) {
    var iconColor = obj.fill;

    instanceArrow.setColor(iconColor);
}

function showSubMenu(type) {
    var $submenu;

    switch (type) {
        case 'shape':
            $submenu = $drawShapeSubMenu;
            break;
        case 'icon':
            $submenu = $iconSubMenu;
            break;
        case 'text':
            $submenu = $textSubMenu;
            break;
        default:
            $submenu = 0;
    }

    $displayingSubMenu.hide();
    $displayingSubMenu = $submenu.show();
}

function applyOrRemoveFilter(applying, type, options) {
    if (applying) {
        imageEditor.applyFilter(type, options).then(result => {
            console.log(result);
        });
    } else {
        imageEditor.removeFilter(type);
    }
}

function image_editor_fn(){
  imageEditor.on({
      objectAdded: function(objectProps) {
          console.info(objectProps);
      },
      undoStackChanged: function(length) {
          if (length) {
              $btnUndo.removeClass('disabled');
          } else {
              $btnUndo.addClass('disabled');
          }
          resizeEditor();
      },
      redoStackChanged: function(length) {
          if (length) {
              $btnRedo.removeClass('disabled');
          } else {
              $btnRedo.addClass('disabled');
          }
          resizeEditor();
      },
      objectScaled: function(obj) {
          if (obj.type === 'text') {
              $inputFontSizeRange.val(obj.fontSize);
          }
      },
      addText: function(pos) {
          imageEditor.addText('Double Click', {
              position: pos.originPosition,
              styles: {
                  fontSize: '150'
               }
          }).then(objectProps => {
              console.log(objectProps);
          });
      },
      objectActivated: function(obj) {
          activeObjectId = obj.id;
          if (obj.type === 'rect' || obj.type === 'circle') {
              showSubMenu('shape');
              setShapeToolbar(obj);
              activateShapeMode();
          } else if (obj.type === 'icon') {
              showSubMenu('icon');
              setIconToolbar(obj);
              activateIconMode();
          } else if (obj.type === 'text') {
              showSubMenu('text');
              setTextToolbar(obj);
              activateTextMode();
          }
      },
      mousedown: function(event, originPointer) {
          if ($imageFilterSubMenu.is(':visible') && imageEditor.hasFilter('colorFilter')) {
              imageEditor.applyFilter('colorFilter', {
                  x: parseInt(originPointer.x, 10),
                  y: parseInt(originPointer.y, 10)
              });
          }
      }
  });
}

function selector_fn() {
  instanceBrush.on('selectColor', function(event) {
      imageEditor.setBrush({
          color: hexToRGBa(event.color, 1.0)
      });
  });

  instanceShape.on('selectColor', function(event) {
    var color = event.color;

    imageEditor.changeShape(activeObjectId, {
        stroke: color
    });

    imageEditor.setDrawingShape(shapeType, shapeOptions);
  });

  instanceText.on('selectColor', function(event) {
    imageEditor.changeTextStyle(activeObjectId, {
        'fill': event.color
    });
  });

  instanceArrow.on('selectColor', function(event) {
    imageEditor.changeIconColor(activeObjectId, event.color);
  });

  // IE9 Unselectable
  $('.menu').on('selectstart', function() {
      return false;
  });
}

function button_events() {
  $("#back-to-archives").on('click', function(){
    $(".nav-tab-archives").tab('show')
  });

  $btnSelection.on('click', function(){
    activateSelectionMode();
  });

  // Attach button click event listeners
  $btns.on('click', function() {
    $btnsActivatable.removeClass('active');
  });

  $btnsActivatable.on('click', function() {
    $(this).addClass('active');
  });

  $("#crop-image").on("click", function(){
    console.log(imageEditor.getCropzoneRect());
    imageEditor.crop(imageEditor.getCropzoneRect());
  });

  $btnUndo.on('click', function() {
    $displayingSubMenu.hide();

    if (!$(this).hasClass('disabled')) {
        imageEditor.undo();
    }
  });

  $btnRedo.on('click', function() {
    $displayingSubMenu.hide();

    if (!$(this).hasClass('disabled')) {
        imageEditor.redo();
    }
  });

  $btnClearObjects.on('click', function() {
    imageEditor.clearObjects();
  });

  $btnClose.on('click', function() {
    imageEditor.stopDrawingMode();
    $displayingSubMenu.hide();
  });

  $inputBrushWidthRange.on('change', function() {
    imageEditor.setBrush({width: 8});//parseInt(this.value, 10)}
  });

  $inputImage.on('change', function(event) {
    var file;

    if (!supportingFileAPI) {
        alert('This browser does not support file-api');
    }

    file = event.target.files[0];
    imageEditor.loadImageFromFile(file).then(result => {
        console.log(result);
        imageEditor.clearUndoStack();
    });
  });

  $btnDownload.on('click', function() {
    var imageName = imageEditor.getImageName();
    var dataURL = imageEditor.toDataURL();
    var blob, type, w;

    if (supportingFileAPI) {
        blob = base64ToBlob(dataURL);
        type = blob.type.split('/')[1];
        if (imageName.split('.').pop() !== type) {
            imageName += '.' + type;
        }

        // Library: FileSaver - saveAs
        saveAs(blob, imageName); // eslint-disable-line
    } else {
        alert('This browser needs a file-server');
        w = window.open();
        w.document.body.innerHTML = '<img src=' + dataURL + '>';
    }
  });

  // control draw line mode
  $btnDrawLinestraight.on('click', function() {
    imageEditor.stopDrawingMode();
    $displayingSubMenu.hide();
    $displayingSubMenu = $drawLineSubMenu.show();
    //$selectLine.eq(0).change();

    var settings = getBrushSettings();
    imageEditor.stopDrawingMode();
    imageEditor.startDrawingMode('LINE_DRAWING', settings);
  });

  $btnDrawLinefree.on('click', function() {
    imageEditor.stopDrawingMode();
    $displayingSubMenu.hide();
    $displayingSubMenu = $drawLineSubMenu.show();
    //$selectLine.eq(0).change();

    var settings = getBrushSettings();
    imageEditor.stopDrawingMode();
    imageEditor.startDrawingMode('FREE_DRAWING', settings);
  });

  // control draw shape mode
  $btnDrawRect.on('click', function() {
    showSubMenu('shape');

    shapeOptions.stroke = '#000000';
    shapeOptions.fill = 'transparent';

    shapeOptions.strokeWidth = 10;//Number($inputStrokeWidthRange.val())

    // step 2. set options to draw shape
    imageEditor.setDrawingShape('rect', shapeOptions);

    // step 3. start drawing shape mode
    activateShapeMode();
  });

  $btnDrawCircle.on('click', function() {
    showSubMenu('shape');

    shapeOptions.stroke = '#000000';
    shapeOptions.fill = 'transparent';

    shapeOptions.strokeWidth = 10;

    // step 2. set options to draw shape
    imageEditor.setDrawingShape('circle', shapeOptions);

    // step 3. start drawing shape mode
    activateShapeMode();
  });

  // control text mode
  $btnText.on('click', function() {
    showSubMenu('text');
    activateTextMode();
  });

  $inputFontSizeRange.on('change', function() {
    imageEditor.changeTextStyle(activeObjectId, {
      fontSize: parseInt(this.value, 10)
    });
  });

  // control icon
  $btnAddIcon.on('click', function() {
    showSubMenu('icon');
    activateIconMode();
    //var element = event.target || event.srcElement;

    imageEditor.once('mousedown', function(e, originPointer) {
        imageEditor.addIcon('arrow', {
            left: originPointer.x,
            top: originPointer.y
        }).then(objectProps => {
            console.log(objectProps);
        });
    });
  });
}

function save_file() {
  $("#btn-save-edited-file").on("click", function() {

    var data, from, onError, onSuccess, settings, to;

    from = moment.utc();
    to = from.clone();
    $(".bb-alert").removeClass("alert-danger").addClass("alert-info");
    NProgress.start();

    data = {
      title: imageEditor.getImageName(),
      from_date: from / 1000,
      to_date: to / 1000,
      type: "edit",
      content: imageEditor.toDataURL(),
      file_extension: "png",
      requested_by: Evercam.User.username
    };

    onError = function(jqXHR, status, error) {
      if (jqXHR.status === 500) {
        Notification.show("Internal Server Error. Please contact to admin.");
      } else {
        Notification.show(jqXHR.responseJSON.message);
      }
      $(".bb-alert").removeClass("alert-info").addClass("alert-danger");
      NProgress.done();
    };

    onSuccess = function(data, status, jqXHR) {
      $(".nav-tab-archives").tab('show')
      NProgress.done();
    };

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onError,
      success: onSuccess,
      type: 'POST',
      url: Evercam.API_URL + "cameras/" + Evercam.Camera.id + "/archives?api_id=" + Evercam.User.api_id + "&api_key=" + Evercam.User.api_key
    };

    $.ajax(settings);
  });
}

function load_image() {
  var image_timestamp = $("#imgPlayback").attr("data-timestamp")
  var url = Evercam.MEDIA_API_URL + "cameras/" + Evercam.Camera.id + "/recordings/snapshots/" + image_timestamp + "?view=true&api_id=" + Evercam.User.api_id + "&api_key=" + Evercam.User.api_key
  image_title = moment.utc(new Date(parseInt(image_timestamp) * 1000)).toISOString();
  imageEditor.loadImageFromURL(url, image_title).then(sizeValue => {
    imageEditor.clearUndoStack();
  });
}

function loading_image() {
  imageEditor.loadImageFromURL("/assets/loader3.gif", "Loading Image").then(sizeValue => {
    imageEditor.clearUndoStack();
  });
}

function model_events() {
  $('.nav-tab-image-editor').on('shown.bs.tab', function(){
    load_image()
  });
}

function initEditorTool(){
  set_variables();
  initImageEditor();
  initColorPicker();
  image_editor_fn();
  selector_fn();
  var $submenu = $iconSubMenu;
  $displayingSubMenu = $submenu.show();
  loading_image();
  button_events();
  model_events()
  save_file()
}

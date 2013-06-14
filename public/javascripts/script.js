var invalidFileTypeMessage = "Sorry, only *.svg and manifest.json";
Dropzone.options.smithUpload = {
  enqueueForUpload: false,
  dictDefaultMessage: "Drop files here to upload (or click)",
  acceptedMimeTypes: "image/svg+xml,application/json",
  dictInvalidFileType: invalidFileTypeMessage,
  accept: function(file, done) {
    if (/\.svg$/.test(file.name) || /manifest.json/.test(file.name)) {
      done();

    } else {
      done(invalidFileTypeMessage);
    }
  }
}

Dropzone.prototype.createThumbnail = function(file){}
Dropzone.autoDiscover = false;

$(function() {
  var manifest = null;
  var sendToServer = function(base64zip) {
    var form = $("#b64upload");
    form.find("input").val(base64zip);
    form.submit();
  };

  var readFile = function(file, callback) {
    var fileReader = new FileReader();
    fileReader.onload = function(e) {
      callback(e, fileReader, file);
    }
    fileReader.readAsBinaryString(file);
  }

  var createSVG = function(rawSVG, container) {
    container.append($(rawSVG).css({width: "100%", height: "100%"}));
  }

  var getPreviewImg = function(filename) {
    return getPreview(filename).find("img");
  }

  var getPreview = function(filename) {
    return $(".dz-filename span:contains('" + filename + "')").closest(".dz-preview");
  }

  var showInfo = function() {
    var info = $(".info");
    info.append($("<span></span>", {"text": manifest.family, "class": "family"}));
    info.append($("<span></span>", {"text": manifest.version, "class": "version"}));

    $.each(manifest.glyphs, function(index, glyph) {
      var preview = getPreview(glyph.name + ".svg");
      var code = $("<span></span>", {"text": glyph.code.replace(/^0x/, '\\')});
      preview.append($("<div></div>", {"class": "code"}).append(code));
    });
  }

  var dropzone = new Dropzone("#smith-upload");

  dropzone.on("addedfile", function(file) {
    readFile(file, function(event) {
      if (/\.svg$/.test(file.name)) {
        var img = getPreviewImg(file.name);
        createSVG(event.target.result, img.parent());

      } if (!manifest && /manifest.json/.test(file.name)) {
        var container = getPreview(file.name);
        container.addClass("manifest-json").append($("<span>json</span>"));
        readFile(file, function(e) {
          manifest = JSON.parse(e.target.result);
          showInfo();
        });
      }
    });
  });

  $("#send").click(function(e) {
    var files = dropzone.files;
    var zip = new JSZip();
    var okFiles = 0;

    $.each(files, function(index, file) {
      readFile(file, function(event) {
        zip.file(file.name, event.target.result);
        okFiles += 1;
      });
    });

    var timer = setInterval(function() {
      if (files.length === okFiles) {
        clearInterval(timer);
        var base64zip = zip.generate();
        sendToServer(base64zip);
      }
    }, 100);
  });
});

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
  var firstChar = 57345;
  var manifest = null;
  var sendToServer = function(base64zip) {
    var form = $("#b64upload");
    form.find("input[name='base64zip']").val(base64zip);
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
    var info = $("#b64upload");
    info.find("input[name='family']").val(manifest.family);
    info.find("input[name='version']").val(manifest.version);

    $.each(manifest.glyphs, function(index, glyph) {
      var preview = getPreview(glyph.name + ".svg");
      preview.find(".code input").val(glyph.code);
    });
  }

  var decimalTohex = function(decimal) {
    return "0x" + decimal.toString(16);
  }

  var generateSimpleManifest = function() {
    var submitForm = $("#b64upload");
    var uploadForm = $("#smith-upload");
    var simpleManifest = {
      family: submitForm.find("input[name='family']").val() || "icosmith-font",
      version: submitForm.find("input[name='version']").val() || "1.0",
      glyphs: []
    };

    uploadForm.find(".code").each(function(index, html) {
      var code = $(html);

      simpleManifest.glyphs.push({
        code: code.find("input").val(),
        name: code.parent().find(".dz-filename span").text().replace(/\.svg$/, '')
      });
    });

    return simpleManifest;
  }

  window.tes = generateSimpleManifest;

  var dropzone = new Dropzone("#smith-upload");

  dropzone.on("addedfile", function(file) {
    readFile(file, function(event) {
      if (/\.svg$/.test(file.name)) {
        var code = $("<input>", {"type": "text", "value": decimalTohex(firstChar++)});
        var preview = getPreview(file.name);
        var img = preview.find("img");

        createSVG(event.target.result, img.parent());
        preview.append($("<div></div>", {"class": "code"}).append(code));

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
    e.preventDefault();

    var files = dropzone.files;
    var totalFiles = files.length;
    var zip = new JSZip();
    var okFiles = 0;

    if (!manifest) {
      manifest = generateSimpleManifest();
      zip.file("manifest.json", JSON.stringify(manifest));
      totalFiles += 1;
      okFiles += 1;
    }

    $.each(files, function(index, file) {
      readFile(file, function(event) {
        zip.file(file.name, event.target.result);
        okFiles += 1;
      });
    });

    var timer = setInterval(function() {
      if (totalFiles === okFiles) {
        clearInterval(timer);
        var base64zip = zip.generate();
        sendToServer(base64zip);
      }
    }, 100);
  });
});

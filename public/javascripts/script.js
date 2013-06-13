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

$(function() {
  var sendToServer = function(base64zip) {
    var form = $("#b64upload");
    form.find("input").val(base64zip);
    form.submit();
  };

  $("#send").click(function(e) {
    var uploader = Dropzone.forElement("#smith-upload");
    var files = uploader.files;
    var zip = new JSZip();
    var okFiles = 0;

    $.each(files, function(index, file) {
      var fileReader = new FileReader();
      fileReader.onload = function(e) {
        zip.file(file.name, e.target.result);
        okFiles += 1;
      }
      fileReader.readAsBinaryString(file);
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

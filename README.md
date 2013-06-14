# FontSmith

```sh
brew install fontforge
brew install ttfautohint
```

```sh
rackup config.ru
```

The application should now be running at localhost:9292.

manifest.json example:
```json
{
  "name": "example1-font",
  "family": "Example1",
  "version": "1.0",
  "copyright": "optional",
  "glyphs": [
    {"code": "0xe001", "name": "svg-name-without-extension"}
  ]
}
```

## Upload Page

1)
![ScreenShot](https://dl-web.dropbox.com/get/fontsmith/screenshots/fontsmith_start_upload.png?w=AADjiWMWnFsT9C2o9dU_Or237N30y4a6EKMZpUt3-bXDew)

2) With your svgs and the manifest.json
![ScreenShot](https://dl-web.dropbox.com/get/fontsmith/screenshots/fontsmith_upload.png?w=AAD7K-JBZkmTSsxkm06Pd4by7n3MsV5fYczspac8RCIMWg)

## Result Page
![ScreenShot](https://dl-web.dropbox.com/get/fontsmith/screenshots/fontsmith_result.png?w=AAC322LFfFkSZ7BZi0qtWs-_9C0PH5gQ34FB1XhH898-Vw)

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
![ScreenShot](https://dl.dropboxusercontent.com/u/1799430/fontsmith/screenshots/fontsmith_start_upload.png)

2) With your svgs and the manifest.json
![ScreenShot](https://dl.dropboxusercontent.com/u/1799430/fontsmith/screenshots/fontsmith_upload.png)

## Result Page
![ScreenShot](https://dl.dropboxusercontent.com/u/1799430/fontsmith/screenshots/fontsmith_result.png)

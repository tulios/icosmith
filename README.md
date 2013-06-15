# IcoSmith

is an open source icon font generator

## How to install

```sh
brew install fontforge
brew install ttfautohint
```

```sh
bundle install
rails s
```

The application should now be running at localhost:3000.

## manifest.json example:

```json
{
  "filename": "my-file-name", // optional
  "name": "example1-font", // optional
  "family": "Example1",
  "version": "1.0",
  "copyright": "some copyright", //optional
  "glyphs": [
    {"code": "0xe001", "name": "svg-name-without-extension"}
  ]
}
```

# IcoSmith

is an open source icon font generator server

## How to install

### MAC OSX
```sh
brew install fontforge
brew install ttfautohint
brew install ttf2eot
```

### CentOS 5.8

FontForge
```sh
wget http://downloads.sourceforge.net/project/fontforge/fontforge-source/fontforge_full-20120731-b.tar.bz2
bunzip fontforge_full-20120731-b.tar.bz2 
tar xvf fontforge_full-20120731-b.tar 
cd fontforge-20120731-b/ ; ./configure; make; make install
```

TTFAutoHint
```sh
wget http://download.savannah.gnu.org/releases/freetype/ttfautohint-0.95.tar.gz
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.4.12.tar.gz
tar xvfz ttfautohint-0.95.tar.gz
tar xvfz freetype-2.4.12.tar.gz
cd freetype-2.4.12 ; ./configure ; make ; make install
cd ttfautohint-0.95 ; ./configure --with-qt=no; make ; make install
```

ttf2eot (check: https://code.google.com/p/ttf2eot/issues/detail?id=26)
```sh
wget https://ttf2eot.googlecode.com/files/ttf2eot-0.0.2-2.tar.gz
tar xvfz ttf2eot-0.0.2-2.tar.gz
cd ttf2eot-0.0.2-2
make
cp ttf2eot /usr/bin
```

### App
```sh
bundle install
rails s
```

The application should now be running at localhost:3000.

## manifest.json example:

```json
{
  "filename": "my-file-name", // optional
  "name": "my-css-font-name", // optional
  "family": "Example1",
  "version": "1.0",
  "copyright": "some copyright", //optional
  "glyphs": [
    {"code": "0xe001", "name": "svg-name-without-extension"}
  ]
}
```

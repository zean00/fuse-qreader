Fuse Qreader
============

Library qr code scanner for [Fuse](http://www.fusetools.com/).

This library is adaptation (the structure and code base) of Fuse Gallery (https://github.com/bolav/fuse-gallery)
The QR Code reader is using built iOS framework and the code is based on sample code by Yannick Loriot (https://github.com/yannickl/QRCodeReaderViewController)

For the Android, still working on it, trying to use Google Play Service API (Google Vision) and based on google vision sample (https://github.com/googlesamples/android-vision)


## Installation

## Build

## Usage

UX:

```
<Qreader ux:Global="Qreader" />
<Text Value="{txt}">
```

JavaScript:

```
var qreader = require('Qreader');
var Observable = require('FuseJS/Observable');
var txt = Observable();

function load () {
 qreader.scan().then(function (res) {
  txt.value = res;
 });
}
module.exports = {
 load: load,
 txt: txt
}
```

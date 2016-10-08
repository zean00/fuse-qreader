Fuse Qreader
============

Library qr code scanner for [Fuse](http://www.fusetools.com/).

This library is adaptation (the structure and code base) of Fuse Gallery (https://github.com/bolav/fuse-gallery)
The QR Code reader is using built iOS framework and the code is based on sample code by Yannick Loriot (https://github.com/yannickl/QRCodeReaderViewController)

The android version is based on google vision sample that use Google Vision API (Part of Google Play Service library) (https://github.com/googlesamples/android-vision)


## Installation

## Build

For android , the fuse build will result error (I'm not sure why but it's questioning '@style\Theme.AppCompat' in AndroidManifest.xml), but you can open and build the project with the android studio and it should be work just fine. Don't forget to install Google Play Service, Google Support Library and NDK before build the project.

You need to add compile dependency manually (the automatic gradle anotation not working)

```
dependencies {
    compile 'com.android.support:support-v4:23.0.1'
    compile 'com.google.android.gms:play-services:9.2.1'
    compile 'com.android.support:design:23.0.1'
    compile 'com.android.support:multidex:1.0.0'
}
```

With the new google play service, you need to enable multidex support in default config

```
def with = defaultConfig.with {
            multiDexEnabled true
            applicationId = "com.apps.qreaderlibrary"
            minSdkVersion.apiLevel = 16
            targetSdkVersion.apiLevel = 23
            versionCode = 0
            versionName = "0.0.0"
        }
```

And update the AndroidManifest file

```
 <application android:label="QreaderLibrary"
                  android:name="android.support.multidex.MultiDexApplication">
```

You might encounter error compilation in generated source code (QreaderLibrary.java), you can comment below code as work around

```
 //android.support.v7.app.AppCompatDelegate.setCompatVectorFromResourcesEnabled(true);
 ```

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

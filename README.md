
# Check App Version

A plugin that allows you to check the **version** of the app installed with a hypothetical version of the app published.

[![Pub Version](https://img.shields.io/pub/v/check_app_version?style=flat-square&logo=dart)](https://pub.dev/packages/check_app_version)
![Pub Likes](https://img.shields.io/pub/likes/check_app_version)
![Pub Points](https://img.shields.io/pub/points/check_app_version)
![Pub Popularity](https://img.shields.io/pub/popularity/check_app_version)
![GitHub license](https://img.shields.io/github/license/enzo-desimone/check_app_version?style=flat-square)

## Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
|:-------:|:---:|:-----:|:---:|:-----:|:-------:|
|    ✔️   |  ✔️  |   ✔️  |  ✔️  |   ✔️  |    ✔️   |

## About

The plugin compares two version codes:
- The code for the app **installed** on the device.
- Code for a new version of the app compiled using **JSON**.

The package acquires the necessary information for the comparison between the two versions through a JSON file compiled by the user.

| Key             | Value                    |
|-----------------|--------------------------|
| app_name        | the name of the app      |
| new_app_version | the new app version      |
| new_app_code    | the new app code         |
| android_package | android app package name |
| ios_package     | ios bundle identifier    |
| windows_package | windows app package name |
| linux_package   | linux app package name   |
| macos_package   | macos app package name   |
| web_package     | web app package name     |
| ios_app_id      | iOS app id number        |

Example of a JSON file at this [link](https://github.com/enzo-desimone/check_app_version/blob/master/example/example.json).

## Installation

### Import the Check App Version package
To use the Check App Version package, follow the [plugin installation instructions](https://pub.dev/packages/check_app_version/install).

### Usage

Add the following import to your Dart code:
```dart
import 'package:check_app_version/app_version_dialog.dart';
```

We offer three options to display the app version dialog:

**AppVersionDialog**

```dart
AppVersionDialog(
  context: context,
  jsonUrl: 'https://besimsoft.com/example.json',
).show();
```

**AppVersionCustomDialog**
```dart
AppVersionCustomDialog(
  context: context,
  jsonUrl: 'https://besimsoft.com/example.json',
  dialogBuilder: (BuildContext context) => AlertDialog(),
).show();
```

**AppVersionCustomDialog**

```dart
AppVersionOverlayDialog(
  context: context,
  jsonUrl: 'https://besimsoft.com/example.json',
  dialogBuilder: (BuildContext context) => AlertDialog(),
).show();
```

### Image Example

<img src="https://raw.githubusercontent.com/enzo-desimone/check_app_version/master/images/android-screen.png" width="350">

### Customize the AppVersionDialog()

In the **AppVersionDialog()** method we have many properties to customize the message dialog.

| Property              | Function                                                                |
|-----------------------|-------------------------------------------------------------------------|
| **jsonUrl**           | **The JSON Link (Required)**                                            |
| **context**           | **The Context of Widget Tree (Required)**                               |
| onPressConfirm        | Void function when pressing confirm button                              |
| onPressDecline        | Void function when pressing decline button                              |
| showWeb               | Show the message dialog on Flutter web app version (default: TRUE)      |
| dialogRadius          | The message dialog border radius value                                  |
| backgroundColor       | The message dialog background color                                     |
| title                 | The dialog message title                                                |
| titleColor            | The dialog message title color                                          |
| body                  | The dialog message body                                                 |
| bodyColor             | The dialog message body color                                           |
| barrierDismissible    | Dismiss the message dialog by tapping the modal barrier (default: TRUE) |
| onWillPop             | Dismiss the message dialog using only the action keys (default: TRUE)   |
| updateButtonText      | The update button text                                                  |
| updateButtonTextColor | The update button text color                                            |
| updateButtonColor     | The update button color                                                 |
| updateButtonRadius    | The update button border radius value                                   |
| laterButtonText       | The later button text                                                   |
| laterButtonColor      | The later button color                                                  |
| laterButtonEnable     | Enable visibility of later button (default: FALSE)                      |
| cupertinoDialog       | Use Cupertino Style for iOS and macOS (default: TRUE)                   |

### Customize the AppVersionCustomDialog()

In the **AppVersionCustomDialog()** method we have many **required** properties.

| Property           | Function                                                                |
|--------------------|-------------------------------------------------------------------------|
| **jsonUrl**        | **The JSON Link (Required)**                                            |
| **context**        | **The Context of Widget Tree (Required)**                               |
| **dialogBuilder**  | **Custom Dialog Builder for use your custom dialog**                    |
| showWeb            | Show the message dialog on Flutter web app version (default: TRUE)      |
| barrierDismissible | Dismiss the message dialog by tapping the modal barrier (default: TRUE) |

### Customize the AppVersionOverlayDialog()

In the **AppVersionOverlayDialog()** method we have many **required** properties.

| Property           | Function                                                                |
|--------------------|-------------------------------------------------------------------------|
| **jsonUrl**        | **The JSON Link (Required)**                                            |
| **context**        | **The Context of Widget Tree (Required)**                               |
| **overlayBuilder** | **Custom Overlay Builder for use your custom dialog**                   |
| showWeb            | Show the message dialog on Flutter web app version (default: TRUE)      |
| barrierDismissible | Dismiss the message dialog by tapping the modal barrier (default: TRUE) |

# Check App Version

A plugin that allows you to check the **version** of the app installed with a hypothetical version of the app published.

[![Pub Version](https://img.shields.io/pub/v/check_app_version?style=flat-square&logo=dart)](https://pub.dev/packages/check_app_version)
![Pub Likes](https://img.shields.io/pub/likes/check_app_version)
![Pub Likes](https://img.shields.io/pub/points/check_app_version)
![Pub Likes](https://img.shields.io/pub/popularity/check_app_version)
![GitHub license](https://img.shields.io/github/license/enzo-desimone/check_app_version?style=flat-square)

## Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✔️    | ✔️  |  ✔️   | ✔️  |  ✔️   |   ✔️    |


## About

The plugin compares two version codes:
- The code for the app **installed** on the device.
- Code for a new version of the app compiled using **JSON**.

In fact the package acquires the necessary information for the comparison between the two versions,
through a JSON file compiled by the user himself.


| Key             |       Value |
|-----------------| ------------- |
| app_name        | the name of the app  |
| new_app_version | the new app version  |
| new_app_code    | the new app code  |
| android_package | android app package name  |
| ios_package     | ios bundle identify  |
| windows_package | android app package name  |
| linux_package   | ios bundle identify  |
| macos_package   | android app package name  |
| web_package     | ios bundle identify  |
| ios_app_id      | iOS app id number  |

Example of a JSON file at this [link](https://github.com/enzo-desimone/check_app_version/blob/master/example/example.json).

## Install


### Import the Check App Version package
To use the Check App Version package, follow the [plugin installation instructions](https://pub.dev/packages/check_app_version/install).


### Use the package

Add the following import to your Dart code:
```dart
import 'package:check_app_version/show_dialog.dart';
```

We now have the option to use the method **ShowDialog(jsonUrl: 'my url').checkVersion();**
to check the version and show a message dialog, remember to replace **'my link'** with the link that
refers to our previously created and customized JSON file

```dart
    ShowDialog(
        context: context,
        jsonUrl: 'https://besimsoft.com/example.json',
        onPressDecline: () {},
        onPressConfirm: () {},
        ).checkVersion();
```

### Image Example

<img src="https://raw.githubusercontent.com/enzo-desimone/check_app_version/master/images/android-screen.png" width="350">


### Customize the message dialog

In the **ShowDialog()** method we have many properties to be able to **customize** massage dialog.


| Property           |       Function |
| ------------- | ------------- |
| **jsonUrl**  | **the JSON Link (Required)** |
| onPressConfirm  | void Function when press confirm button (Required) |
| onPressDecline  | void Function when press decline button (Required) |
| showWeb  | show the message dialog on flutter web app version (default: TRUE) |
| dialogRadius  | the message dialog border radius value  |
| backgroundColor  | the message dialog background color  |
| title  | the dialog message title  |
| titleColor  | the dialog message title color  |
| body  | the dialog message body  |
| bodyColor  | the dialog message body color  |
| barrierDismissible  | dismiss the message dialog by tapping the modal barrier (default: TRUE) |
| onWillPop  | disappear the message dialog using only the action keys (default: TRUE)   |
| updateButtonText  | the update button text  |
| updateButtonTextColor  | the update button text color  |
| updateButtonColor  | the update button text color  |
| updateButtonRadius  | the update button text border radius value  |
| laterButtonText  | the later button text  |
| laterButtonColor  | the later button color  |
| laterButtonEnable  | enable visibility of later button (default: FALSE)  |
| cupertinoDialog  | use Cupertino Style for iOS and macOS (default: TRUE)  |

# Check App Version (Flutter)

A plugin that allows you to check the **version** of the app installed with a hypothetical version of the app published on the PlayStore / AppStore.

## About

The plugin compares two version codes:
- The code for the app **installed** on the device.
- Code for a new version of the app compiled using **JSON**.

In fact the package acquires the necessary information for the comparison between the two versions, 
through a JSON file compiled by the user himself.

Example of a JSON file at this [link](https://github.com/enzo-desimone/check_app_version/blob/master/example/example.json).

| Key           |       Value |
| ------------- | ------------- |
| app_name  | the name of the app  |
| new_app_version  | the new app version  |
| new_app_code  | the new app code  |
| play_store_url  | the play store app link  |
| app_store_url  | the app store app link  |
| app_package  | app package name  |

## Install


### Import the StarMenu package
To use the StarMenu plugin, follow the [plugin installation instructions](https://pub.dartlang.org/packages/star_menu#pub-pkg-tab-installing).

### Use the package

Add the following import to your Dart code:
```dart
import 'package:star_menu/star_menu.dart';
```

We can now use a function to build StarMenu widget and open it within an user event with the _StarMenuController.displayStarMenu()_ method.



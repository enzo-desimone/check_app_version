
# Check App Version

A Flutter plugin to compare the **installed app version** with a hypothetical published version of your app.

[![Pub Version](https://img.shields.io/pub/v/check_app_version?style=flat-square&logo=dart)](https://pub.dev/packages/check_app_version)
![Pub Likes](https://img.shields.io/pub/likes/check_app_version)
![Pub Points](https://img.shields.io/pub/points/check_app_version)
![Pub Popularity](https://img.shields.io/pub/popularity/check_app_version)
![GitHub license](https://img.shields.io/github/license/enzo-desimone/check_app_version?style=flat-square)


## 📱 Supported Platforms

| Android | iOS | MacOS | Web | Linux | Windows |
|:-------:|:---:|:-----:|:---:|:-----:|:-------:|
|    ✔️   |  ✔️  |   ✔️  |  ✔️  |   ✔️  |    ✔️   |


## 🔍 Overview

This plugin compares two versions of your app:
- The currently **installed** app version on the user's device
- A **new release** version defined in a JSON file

The plugin retrieves all necessary information for this comparison through a JSON file that you configure.


## 📋 JSON Structure

| Key             | Description                                  |
|-----------------|----------------------------------------------|
| app_name        | Your application name                        |
| new_app_version | New app version (e.g., "1.2.3")              |
| new_app_code    | New app build number                         |
| android_package | Android package name                         |
| ios_package     | iOS bundle identifier                        |
| windows_package | Windows app package name                     |
| linux_package   | Linux app package name                       |
| macos_package   | macOS app package name                       |
| web_package     | Web app package name                         |
| ios_app_id      | iOS app ID number for App Store redirection  |

👉 [Sample JSON file](https://github.com/enzo-desimone/check_app_version/blob/master/example/example.json)


## ⚙️ Installation

### Import the Check App Version package
To use the Check App Version package, follow the [plugin installation instructions](https://pub.dev/packages/check_app_version/install).

### Basic Usage

Add the following import to your Dart code:
```dart
import 'package:check_app_version/app_version_dialog.dart';
```


## 🧩 Display Options

The plugin offers three different ways to display the version update dialog:

### 1. AppVersionDialog
The standard pre-configured dialog:

```dart
AppVersionDialog(
  context: context,
  jsonUrl: 'https://example.com/app_version.json',
).show();
```

### 2. AppVersionCustomDialog
A dialog you can customize with your own builder:

```dart
AppVersionCustomDialog(
  context: context,
  jsonUrl: 'https://example.com/app_version.json',
  dialogBuilder: (BuildContext context) => AlertDialog(
    // Your custom dialog here
  ),
).show();
```

### 3. AppVersionOverlayDialog
A customizable overlay on top of your UI:

```dart
AppVersionOverlayDialog(
  context: context,
  jsonUrl: 'https://example.com/app_version.json',
  overlayBuilder: (BuildContext context) => AlertDialog(
    // Your custom overlay here
  ),
).show();
```


## 🖼️ Example

<img src="https://raw.githubusercontent.com/enzo-desimone/check_app_version/master/images/android-screen.png" width="350" alt="Example update dialog on Android">


## 🎨 Customization

### AppVersionDialog Options

| Property               | Description                                   | Type     | Default                | Required |
|------------------------|-----------------------------------------------|----------|------------------------|:--------:|
| jsonUrl                | URL to your JSON file                         | String   | -                      | ✅       |
| context                | BuildContext from widget tree                 | BuildContext | -                  | ✅       |
| onPressConfirm         | Function called when update button is pressed | Function | null                   | ❌       |
| onPressDecline         | Function called when decline button is pressed| Function | null                   | ❌       |
| showWeb                | Show dialog in Flutter web apps               | bool     | true                   | ❌       |
| dialogRadius           | Border radius of the dialog                   | double   | 8.0                    | ❌       |
| backgroundColor        | Background color of the dialog                | Color    | Colors.white           | ❌       |
| title                  | Dialog title text                             | String   | "New Version Available" | ❌       |
| titleColor             | Color of the dialog title                     | Color    | Colors.black           | ❌       |
| body                   | Dialog message body                           | String   | "A new version is available. Update now for the latest features." | ❌ |
| bodyColor              | Color of the message body                     | Color    | Colors.black54         | ❌       |
| barrierDismissible     | Close dialog by tapping outside               | bool     | true                   | ❌       |
| onWillPop              | Close dialog only using action buttons        | bool     | true                   | ❌       |
| updateButtonText       | Text for the update button                    | String   | "Update Now"           | ❌       |
| updateButtonTextColor  | Text color for the update button              | Color    | Colors.white           | ❌       |
| updateButtonColor      | Background color of the update button         | Color    | Colors.blue            | ❌       |
| updateButtonRadius     | Border radius of the update button            | double   | 4.0                    | ❌       |
| laterButtonText        | Text for the "Later" button                   | String   | "Later"                | ❌       |
| laterButtonColor       | Color of the "Later" button                   | Color    | Colors.grey            | ❌       |
| laterButtonEnable      | Show the "Later" button                       | bool     | false                  | ❌       |
| cupertinoDialog        | Use Cupertino style on iOS and macOS          | bool     | true                   | ❌       |

### AppVersionCustomDialog Options

| Property            | Description                                  | Type                      | Default | Required |
|---------------------|----------------------------------------------|---------------------------|---------|:--------:|
| jsonUrl             | URL to your JSON file                        | String                    | -       | ✅       |
| context             | BuildContext from widget tree                | BuildContext              | -       | ✅       |
| dialogBuilder       | Custom dialog builder function               | Widget Function(BuildContext) | -   | ✅       |
| showWeb             | Show dialog in Flutter web apps              | bool                      | true    | ❌       |
| barrierDismissible  | Close dialog by tapping outside              | bool                      | true    | ❌       |

### AppVersionOverlayDialog Options

| Property            | Description                                  | Type                      | Default | Required |
|---------------------|----------------------------------------------|---------------------------|---------|:--------:|
| jsonUrl             | URL to your JSON file                        | String                    | -       | ✅       |
| context             | BuildContext from widget tree                | BuildContext              | -       | ✅       |
| overlayBuilder      | Custom overlay builder function              | Widget Function(BuildContext) | -   | ✅       |
| showWeb             | Show dialog in Flutter web apps              | bool                      | true    | ❌       |
| barrierDismissible  | Close dialog by tapping outside              | bool                      | true    | ❌       |


## 📝 Version Comparison Logic

The plugin automatically compares the installed version with the one specified in your JSON to determine if an update is needed. The comparison is performed on both the semantic version number and the app build code.


## 🔄 Complete Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:check_app_version/app_version_dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Check for updates when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdates();
    });
  }

  void checkForUpdates() {
    AppVersionDialog(
      context: context,
      jsonUrl: 'https://yourdomain.com/app_version.json',
      onPressConfirm: () {
        // Action when user chooses to update
        print('User chose to update');
      },
      onPressDecline: () {
        // Action when user declines update
        print('User chose to postpone');
      },
      laterButtonEnable: true,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Check App Version Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: checkForUpdates,
          child: Text('Check for Updates'),
        ),
      ),
    );
  }
}
```


## 💡 Common Use Cases

- **Mandatory updates**: Use `laterButtonEnable: false` to force updates
- **Periodic notifications**: Show the dialog only after a certain period since dismissal
- **A/B update testing**: Use different JSON files for different user segments
- **Cross-platform consistency**: Ensure the same update behavior across all platforms


## 🤝 Contributing

Contributions are welcome! Open an [issue](https://github.com/enzo-desimone/check_app_version/issues) or submit a [pull request](https://github.com/enzo-desimone/check_app_version/pulls).


## 📃 License

This package is released under the MIT license. See the [LICENSE](https://github.com/enzo-desimone/check_app_version/blob/master/LICENSE) file for more details.
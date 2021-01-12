# Check App Version (Flutter)

A plugin that allows you to check the version of the app installed with a hypothetical version of the app published on the PlayStore / AppStore.

## About

The plugin compares two version codes:
- The code for the app installed on the device.
- Code for a new version of the app compiled using JSON.

In fact the package acquires the necessary information for the comparison between the two versions, 
through a JSON file compiled by the user himself.

Example of a JSON file at this [link](https://flutter.dev/developing-packages/).

| Key           |       Value |
| ------------- | ------------- |
| app_name  | the name of the app  |
| new_app_version  | the new app version  |
| new_app_code  | the new app code  |
| play_store_url  | the play store app link  |
| app_store_url  | the app store app link  |
| app_package  | app package name  |


For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

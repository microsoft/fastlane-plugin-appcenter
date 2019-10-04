# App Center `fastlane` plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-appcenter)
[![Gem Version](https://badge.fury.io/rb/fastlane-plugin-appcenter.svg)](https://badge.fury.io/rb/fastlane-plugin-appcenter)
[![Build Status](https://travis-ci.org/microsoft/fastlane-plugin-appcenter.svg?branch=master)](https://travis-ci.org/microsoft/fastlane-plugin-appcenter)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-appcenter`, add it to your project by running:

```bash
fastlane add_plugin appcenter
```

## About App Center
With [App Center](https://appcenter.ms) you can continuously build, test, release, and monitor your apps. This plugin provides an `appcenter_upload` action which allows you to upload and [release distribute](https://docs.microsoft.com/en-us/appcenter/distribution/uploading) apps to your testers on App Center as well as to upload .dSYM files to [collect detailed crash reports](https://docs.microsoft.com/en-us/appcenter/crashes/ios) in App Center.

## Usage

To get started, first, [obtain an API token](https://appcenter.ms/settings/apitokens) in App Center. The API Token is used to authenticate with the App Center API in each call.

```ruby
appcenter_upload(
  api_token: "<appcenter token>",
  owner_name: "<appcenter account name of the owner of the app (username or organization URL name)>",
  app_name: "<appcenter app name>",
  apk: "<path to android build binary>",
  notify_testers: true # Set to false if you don't want to notify testers of your new release (default: `false`)
)
```

### Help

Once installed, information and help can be printed out with this command:
```bash
fastlane action appcenter_upload
```

### A note on App Name

The `app_name` and `owner_name` as set in the Fastfile come from the app's URL in App Center, in the below form:
```
https://appcenter.ms/users/{owner_name}/apps/{app_name}
```
They should not be confused with the displayed name on App Center pages, which is called `app_display_name ` instead.

### Parameters

The action parameters `api_token` and `owner_name` can also be omitted when their values are [set as environment variables](https://docs.fastlane.tools/advanced/#environment-variables).
Here is the list of all existing parameters:

| Key                   | Description                                      | Env Var                                          | Default            |
|-----------------------|--------------------------------------------------|--------------------------------------------------|--------------------|
| `api_token`           | API Token for App Center                                                                              | `APPCENTER_API_TOKEN`                              |                    |
| `owner_type`          | Owner type, either 'user' or 'organization'                                                           | `APPCENTER_OWNER_TYPE`                             | `user`               |
| `owner_name`          | Owner name, as found in the App's URL in App Center                                                   | `APPCENTER_OWNER_NAME`                             |                    |
| `app_name`            | App name as found in the App's URL in App Center, if there is no app with such name, you will be prompted to create one     | `APPCENTER_APP_NAME`                               |                    |
| `app_display_name`    | App display name to use when creating a new app                                                       | `APPCENTER_APP_DISPLAY_NAME`                       |                    |
| `app_os`              | App OS. Used for new app creation, if app 'app_name' was not found                                    | `APPCENTER_APP_OS`                                 |                    |
| `app_platform`        | App Platform. Used for new app creation, if app 'app_name' was not found                              | `APPCENTER_APP_PLATFORM`                           |                    |
| `apk`                 | Build release path for android build                                                                  | `APPCENTER_DISTRIBUTE_APK`                         |                    |
| `aab`                 | Build release path for android app bundle build                                                       | `APPCENTER_DISTRIBUTE_AAB`                         |                    |
| `ipa`                 | Build release path for iOS builds                                                                     | `APPCENTER_DISTRIBUTE_IPA`                         |                    |
| `file`                | Build release path for generic builds (.aab, .app, .app.zip, .apk, .dmg, .ipa, .pkg)                  | `APPCENTER_DISTRIBUTE_FILE`                        |                    |
| `dsym`                | Path to your symbols file. For iOS provide path to app.dSYM.zip                                       | `APPCENTER_DISTRIBUTE_DSYM`                        |                    |
| `upload_dsym_only`    | Flag to upload only the dSYM file to App Center                                                       | `APPCENTER_DISTRIBUTE_UPLOAD_DSYM_ONLY`            | `false`              |
| `mapping`             | Path to your Android mapping.txt                                                                      | `APPCENTER_DISTRIBUTE_ANDROID_MAPPING`             |                    |
| `upload_mapping_only` | Flag to upload only the mapping.txt file to App Center                                                | `APPCENTER_DISTRIBUTE_UPLOAD_ANDROID_MAPPING_ONLY` | `false`              |
| `destinations`        | Comma separated list of destination names. Both distribution groups and stores are supported. All names are required to be of the same destination type    | `APPCENTER_DISTRIBUTE_DESTINATIONS`                | `Collaborators`      |
| `destination_type`    | Destination type of distribution destination. 'group' and 'store' are supported                       | `APPCENTER_DISTRIBUTE_DESTINATION_TYPE`            | `group`              |
| `mandatory_update`    | Require users to update to this release. Ignored if destination type is 'store'                       | `APPCENTER_DISTRIBUTE_MANDATORY_UPDATE`            | `false`              |
| `notify_testers`      | Send email notification about release. Ignored if destination type is 'store'                         | `APPCENTER_DISTRIBUTE_NOTIFY_TESTERS`              | `false`              |
| `release_notes`       | Release notes                                                                                         | `APPCENTER_DISTRIBUTE_RELEASE_NOTES`               | No changelog given |
| `should_clip`         | Clip release notes if its length is more then 5000, true by default                                   | `APPCENTER_DISTRIBUTE_RELEASE_NOTES_CLIPPING`      | `true`               |
| `release_notes_link`  | Additional release notes link                                                                         | `APPCENTER_DISTRIBUTE_RELEASE_NOTES_LINK`          |                    |
| `build_number`        | The build number, required for Android ProGuard mapping files, as well as macOS .pkg and .dmg builds  | `APPCENTER_DISTRIBUTE_BUILD_NUMBER`                |                    |
| `version`             | The build version, required for Android ProGuard mapping files, as well as macOS .pkg and .dmg builds | `APPCENTER_DISTRIBUTE_VERSION`                     |                    |
| `timeout`             | Request timeout in seconds                                                                            | `APPCENTER_DISTRIBUTE_TIMEOUT`                     |                    |

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

Sample uses `.env` for setting private variables like API token, owner name, .etc. You need to replace it in `Fastfile` by your own values.

There are three examples in `test` lane:
- upload release for android with minimum required parameters
- upload release for ios with all set parameters
- upload only dSYM file for ios

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please open a [GitHub issue](https://github.com/microsoft/fastlane-plugin-appcenter/issues).

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## Contributing

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Contact

We're on Twitter as [@vsappcenter](https://www.twitter.com/vsappcenter). Additionally you can reach out to us on the [App Center](https://appcenter.ms/apps) portal by using the blue Intercom button on the bottom right to start a conversation.

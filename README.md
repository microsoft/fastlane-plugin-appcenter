# appcenter plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-appcenter)
[![Gem Version](https://badge.fury.io/rb/fastlane-plugin-appcenter.svg)](https://badge.fury.io/rb/fastlane-plugin-appcenter)
[![Build Status](https://travis-ci.org/Microsoft/fastlane-plugin-appcenter.svg?branch=master)](https://travis-ci.org/Microsoft/fastlane-plugin-appcenter)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-appcenter`, add it to your project by running:

```bash
fastlane add_plugin appcenter
```

## About appcenter

Plugin for [App Center](https://appcenter.ms). Provides `appcenter_upload` action for [release distribution](https://docs.microsoft.com/en-us/appcenter/distribution/uploading) and [dSYM uploads](https://docs.microsoft.com/en-us/appcenter/crashes/ios)

## Usage

[Obtain an API token](https://appcenter.ms/settings/apitokens). API Token is used for authentication for all App Center API calls.

```ruby
appcenter_upload(
  api_token: "<appcenter token>",
  owner_name: "<your appcenter account name>",
  app_name: "<your app name>",
  apk: "<path to android build binary>"
)
```

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

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## Contributing

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Contact

### Intercom

If you have further questions, want to provide feedback or you are running into issues, log in to the [App Center](https://appcenter.ms) portal and use the blue Intercom button on the bottom right to start a conversation with us.

### Twitter

We're on Twitter as [@appcenter](https://www.twitter.com/vsappcenter).

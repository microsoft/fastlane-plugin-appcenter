$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'webmock'
require 'webmock/rspec'

# Enable strict mode for tests
ENV['APPCENTER_STRICT_MODE'] = "true"

def stub_request(*args)
  WebMock::API.stub_request(*args)
end

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/appcenter' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

RSpec.configure do |config|
  config.before(:all) {
    $mime_types = {
      apk: "application/vnd.android.package-archive",
      aab: "application/vnd.android.package-archive",
      msi: "application/x-msi",
      plist: "application/xml",
      aetx: "application/c-x509-ca-cert",
      cer: "application/pkix-cert",
      xap: "application/x-silverlight-app",
      appx: "application/x-appx",
      appxbundle: "application/x-appxbundle",
      appxupload: "application/x-appxupload",
      appxsym: "application/x-appxupload",
      msix: "application/x-msix",
      msixbundle: "application/x-msixbundle",
      msixupload: "application/x-msixupload",
      msixsym: "application/x-msixupload"
    }
  }
end

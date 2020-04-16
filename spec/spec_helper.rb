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

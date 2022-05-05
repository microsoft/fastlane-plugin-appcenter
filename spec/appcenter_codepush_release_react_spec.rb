require_relative 'appcenter_stub'
require_relative 'upload_stubs'

describe Fastlane::Actions::AppcenterCodepushReleaseReactAction do
  describe '#run' do
    before :each do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      # allow(Fastlane::Actions::AppcenterCodepushReleaseReactAction).to receive(:sh).with(/npm exec/).and_return(nil)
    end

    it "can use a local appcenter_cli" do
      allow(Fastlane::Actions::AppcenterCodepushReleaseReactAction).to receive(:sh).with(/npm exec/).and_return(nil)
      Fastlane::FastFile.new.parse("lane :test_codepush do
        appcenter_codepush_release_react(
          api_token: 'an-api-token',
          owner_name: 'owner',
          app_name: 'app',
          deployment: 'Staging',
          use_local_appcenter_cli: true
        )
      end").runner.execute(:test_codepush)
    end
  end
end


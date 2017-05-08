def stub_create_release_upload(status)
  stub_request(:post, "https://api.mobile.azure.com/v0.1/apps/owner/app/release_uploads")
    .with(body: "{}")
    .to_return(
      status: status,
      body: "{\"upload_id\":\"upload_id\",\"upload_url\":\"https://upload.com\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_dsym_upload(status)
  stub_request(:post, "https://api.mobile.azure.com/v0.1/apps/owner/app/symbol_uploads")
    .with(body: "{\"symbol_type\":\"Apple\"}")
    .to_return(
      status: status,
      body: "{\"symbol_upload_id\":\"symbol_upload_id\",\"upload_url\":\"https://upload_dsym.com\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_upload_build(status)
  stub_request(:post, "https://upload.com/")
    .to_return(status: status, body: "", headers: {})
end

def stub_upload_dsym(status)
  stub_request(:put, "https://upload_dsym.com/")
    .to_return(status: status, body: "", headers: {})
end

def stub_update_release_upload(status, release_status)
  stub_request(:patch, "https://api.mobile.azure.com/v0.1/apps/owner/app/release_uploads/upload_id")
    .with(
      body: "{\"status\":\"#{release_status}\"}"
    )
    .to_return(status: status, body: "{\"release_url\":\"v0.1/apps/owner/app/releases/1\"}", headers: {})
end

def stub_update_dsym_upload(status, release_status)
  stub_request(:patch, "https://api.mobile.azure.com/v0.1/apps/owner/app/symbol_uploads/symbol_upload_id")
    .with(
      body: "{\"status\":\"#{release_status}\"}"
    )
    .to_return(status: status, body: "{\"release_url\":\"v0.1/apps/owner/app/releases/1\"}", headers: {})
end

def stub_add_to_group(status)
  stub_request(:patch, "https://api.mobile.azure.com/release_url")
    .to_return(status: status, body: "{\"short_version\":\"1.0\",\"download_link\":\"https://download.link\"}", headers: { 'Content-Type' => 'application/json' })
end

describe Fastlane::Actions::MobileCenterUploadAction do
  describe '#run' do
    before :each do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
    end

    it "raises an error if no api token was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            owner_name: 'owner',
            app_name: 'app',
            group: 'Testers',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("No API token for Mobile Center given, pass using `api_token: 'token'`")
    end

    it "raises an error if no owner name was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            api_token: 'xxx',
            app_name: 'app',
            group: 'Testers',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("No Owner name for Mobile Center given, pass using `owner_name: 'name'`")
    end

    it "raises an error if no app name was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            group: 'Testers',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("No App name given, pass using `app_name: 'app name'`")
    end

    it "raises an error if no build file was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            group: 'Testers'
          })
        end").runner.execute(:test)
      end.to raise_error("Couldn't find build file at path ''")
    end

    it "raises an error if given apk was not found" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            group: 'Testers',
            apk: './nothing.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("Couldn't find build file at path './nothing.apk'")
    end

    it "raises an error if given ipa was not found" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            group: 'Testers',
            ipa: './nothing.ipa'
          })
        end").runner.execute(:test)
      end.to raise_error("Couldn't find build file at path './nothing.ipa'")
    end

    it "raises an error if given file has invalid extension for apk" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            group: 'Testers',
            apk: './spec/fixtures/appfiles/Appfile_empty'
          })
        end").runner.execute(:test)
      end.to raise_error("Only \".apk\" formats are allowed, you provided \"\"")
    end

    it "raises an error if given file has invalid extension for ipa" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            group: 'Testers',
            ipa: './spec/fixtures/appfiles/Appfile_empty'
          })
        end").runner.execute(:test)
      end.to raise_error("Only \".ipa\" formats are allowed, you provided \"\"")
    end

    it "raises an error if both ipa and apk provided" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            group: 'Testers',
            ipa: './spec/fixtures/appfiles/ipa_file_empty.ipa',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("You can't use 'ipa' and 'apk' options in one run")
    end

    it "handles upload build error" do
      stub_create_release_upload(200)
      stub_upload_build(400)
      stub_update_release_upload(200, 'aborted')

      Fastlane::FastFile.new.parse("lane :test do
        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "handles not found owner or app error" do
      stub_create_release_upload(404)

      Fastlane::FastFile.new.parse("lane :test do
        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "handles not found distribution group" do
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_add_to_group(404)

      Fastlane::FastFile.new.parse("lane :test do
        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "can use a generated changelog as release notes" do
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_add_to_group(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::FL_CHANGELOG] = 'autogenerated changelog'

        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)

      expect(values[:release_notes]).to eq('autogenerated changelog')
    end

    it "works with valid parameters for android" do
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_add_to_group(200)

      Fastlane::FastFile.new.parse("lane :test do
        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "uses GRADLE_APK_OUTPUT_PATH as default for apk" do
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_add_to_group(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] = './spec/fixtures/appfiles/apk_file_empty.apk'

        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          group: 'Testers'
        })
      end").runner.execute(:test)

      expect(values[:apk]).to eq('./spec/fixtures/appfiles/apk_file_empty.apk')
    end

    it "uses IPA_OUTPUT_PATH as default for ipa" do
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_add_to_group(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = './spec/fixtures/appfiles/ipa_file_empty.ipa'

        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          group: 'Testers'
        })
      end").runner.execute(:test)

      expect(values[:ipa]).to eq('./spec/fixtures/appfiles/ipa_file_empty.ipa')
    end

    it "works with valid parameters for ios" do
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_add_to_group(200)
      stub_create_dsym_upload(200)
      stub_upload_dsym(200)
      stub_update_dsym_upload(200, "committed")

      Fastlane::FastFile.new.parse("lane :test do
        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          ipa: './spec/fixtures/appfiles/ipa_file_empty.ipa',
          dsym: './spec/fixtures/symbols/Themoji.dSYM.zip',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "zips dSYM files if dsym parameter is folder" do
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_add_to_group(200)
      stub_create_dsym_upload(200)
      stub_upload_dsym(200)
      stub_update_dsym_upload(200, "committed")

      values = Fastlane::FastFile.new.parse("lane :test do
        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          ipa: './spec/fixtures/appfiles/ipa_file_empty.ipa',
          dsym: './spec/fixtures/symbols/Themoji.dSYM',
          group: 'Testers'
        })
      end").runner.execute(:test)

      expect(values[:dsym_path].end_with?(".zip")).to eq(true)
    end

    it "allows to send a dsym only" do
      stub_create_dsym_upload(200)
      stub_upload_dsym(200)
      stub_update_dsym_upload(200, "committed")

      Fastlane::FastFile.new.parse("lane :test do
        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          upload_dsym_only: true,
          dsym: './spec/fixtures/symbols/Themoji.dSYM.zip'
        })
      end").runner.execute(:test)
    end

    it "uses DSYM_OUTPUT_PATH as default for dsym" do
      stub_create_dsym_upload(200)
      stub_upload_dsym(200)
      stub_update_dsym_upload(200, "committed")

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = './spec/fixtures/symbols/Themoji.dSYM.zip'

        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          upload_dsym_only: true,
        })
      end").runner.execute(:test)

      expect(values[:dsym_path]).to eq('./spec/fixtures/symbols/Themoji.dSYM.zip')
    end

    it "handles invalid token error" do
      expect do
        stub_create_release_upload(401)

        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            group: 'Testers'
          })
        end").runner.execute(:test)
      end.to raise_error("Auth Error, provided invalid token")
    end

    it "handles invalid token error in dSYM upload" do
      expect do
        stub_create_dsym_upload(401)

        Fastlane::FastFile.new.parse("lane :test do
          mobile_center_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            upload_dsym_only: true,
            dsym: './spec/fixtures/symbols/Themoji.dSYM.zip'
          })
        end").runner.execute(:test)
      end.to raise_error("Auth Error, provided invalid token")
    end

    it "handles upload dSYM error" do
      stub_create_dsym_upload(200)
      stub_upload_dsym(400)
      stub_update_dsym_upload(200, 'aborted')

      Fastlane::FastFile.new.parse("lane :test do
        mobile_center_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          upload_dsym_only: true,
          dsym: './spec/fixtures/symbols/Themoji.dSYM.zip'
        })
      end").runner.execute(:test)
    end
  end
end
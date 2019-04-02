def stub_check_app(status)
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/owner/app")
    .to_return(
      status: status,
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_app(status)
  stub_request(:post, "https://api.appcenter.ms/v0.1/apps")
    .to_return(
      status: status,
      body: "{\"name\":\"app\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_release_upload(status)
  stub_request(:post, "https://api.appcenter.ms/v0.1/apps/owner/app/release_uploads")
    .with(body: "{}")
    .to_return(
      status: status,
      body: "{\"upload_id\":\"upload_id\",\"upload_url\":\"https://upload.com\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_dsym_upload(status)
  stub_request(:post, "https://api.appcenter.ms/v0.1/apps/owner/app/symbol_uploads")
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
  stub_request(:patch, "https://api.appcenter.ms/v0.1/apps/owner/app/release_uploads/upload_id")
    .with(
      body: "{\"status\":\"#{release_status}\"}"
    )
    .to_return(status: status, body: "{\"release_id\":\"1\"}", headers: { 'Content-Type' => 'application/json' })
end

def stub_update_dsym_upload(status, release_status)
  stub_request(:patch, "https://api.appcenter.ms/v0.1/apps/owner/app/symbol_uploads/symbol_upload_id")
    .with(
      body: "{\"status\":\"#{release_status}\"}"
    )
    .to_return(status: status, body: "{\"release_id\":\"1\"}", headers: { 'Content-Type' => 'application/json' })
end

def stub_get_group(status, group_name = "Testers")
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/owner/app/distribution_groups/#{group_name}")
    .to_return(status: status, body: "{\"id\":\"1\"}", headers: { 'Content-Type' => 'application/json' })
end

def stub_get_release(status)
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/owner/app/releases/1")
    .to_return(status: status, body: "{\"short_version\":\"1.0\",\"download_link\":\"https://download.link\"}", headers: { 'Content-Type' => 'application/json' })
end

def stub_add_to_group(status)
  stub_request(:post, "https://api.appcenter.ms/v0.1/apps/owner/app/releases/1/groups")
    .to_return(status: status, body: "{\"short_version\":\"1.0\",\"download_link\":\"https://download.link\"}", headers: { 'Content-Type' => 'application/json' })
end

describe Fastlane::Actions::AppcenterUploadAction do
  describe '#run' do
    before :each do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
    end

    it "raises an error if no api token was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            owner_name: 'owner',
            app_name: 'app',
            group: 'Testers',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("No API token for App Center given, pass using `api_token: 'token'`")
    end

    it "raises an error if no owner name was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            app_name: 'app',
            group: 'Testers',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("No Owner name for App Center given, pass using `owner_name: 'name'`")
    end

    it "raises an error if no app name was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
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
        stub_check_app(200)
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
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
        stub_check_app(200)
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
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
        stub_check_app(200)
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
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
          appcenter_upload({
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
          appcenter_upload({
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
          appcenter_upload({
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
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(400)
      stub_update_release_upload(200, 'aborted')

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "handles not found owner or app error" do
      stub_check_app(200)
      stub_create_release_upload(404)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "handles not found distribution group" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(404)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "handles not found release" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(200)
      stub_add_to_group(200)
      stub_get_release(404)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "can use a generated changelog as release notes" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(200)
      stub_add_to_group(200)
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::FL_CHANGELOG] = 'autogenerated changelog'

        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)

      expect(values[:release_notes]).to eq('autogenerated changelog')
    end

    it "clips changelog if its lenght is more then 5000" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(200)
      stub_add_to_group(200)
      stub_get_release(200)

      release_notes = '_' * 6000
      read_more = '...'
      release_notes_clipped = release_notes[0, 5000 - read_more.length] + read_more

      values = Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers',
          release_notes: '#{release_notes}'
        })
      end").runner.execute(:test)

      expect(values[:release_notes]).to eq(release_notes_clipped)
    end

    it "clips changelog and adds link in the end if its lenght is more then 5000" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(200)
      stub_add_to_group(200)
      stub_get_release(200)

      release_notes = '_' * 6000
      release_notes_link = 'https://text.com'
      read_more = "...\n\n[read more](#{release_notes_link})"
      release_notes_clipped = release_notes[0, 5000 - read_more.length] + read_more

      values = Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers',
          release_notes: '#{release_notes}',
          release_notes_link: '#{release_notes_link}'
        })
      end").runner.execute(:test)

      expect(values[:release_notes]).to eq(release_notes_clipped)
    end

    it "works with valid parameters for android" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(200)
      stub_add_to_group(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "uses GRADLE_APK_OUTPUT_PATH as default for apk" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(200)
      stub_add_to_group(200)
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] = './spec/fixtures/appfiles/apk_file_empty.apk'

        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          group: 'Testers'
        })
      end").runner.execute(:test)

      expect(values[:apk]).to eq('./spec/fixtures/appfiles/apk_file_empty.apk')
    end

    it "uses IPA_OUTPUT_PATH as default for ipa" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(200)
      stub_add_to_group(200)
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = './spec/fixtures/appfiles/ipa_file_empty.ipa'

        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          group: 'Testers'
        })
      end").runner.execute(:test)

      expect(values[:ipa]).to eq('./spec/fixtures/appfiles/ipa_file_empty.ipa')
    end

    it "works with valid parameters for ios" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(200)
      stub_add_to_group(200)
      stub_get_release(200)
      stub_create_dsym_upload(200)
      stub_upload_dsym(200)
      stub_update_dsym_upload(200, "committed")

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          ipa: './spec/fixtures/appfiles/ipa_file_empty.ipa',
          dsym: './spec/fixtures/symbols/Themoji.dSYM.zip',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "adds to all provided groups" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_update_release_upload(200, 'committed')
      stub_update_release_upload(200, 'committed')
      stub_get_group(200, 'Testers1')
      stub_get_group(200, 'Testers2')
      stub_get_group(200, 'Testers3')
      stub_add_to_group(200)
      stub_add_to_group(200)
      stub_add_to_group(200)
      stub_get_release(200)
      stub_create_dsym_upload(200)
      stub_upload_dsym(200)
      stub_update_dsym_upload(200, "committed")

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          ipa: './spec/fixtures/appfiles/ipa_file_empty.ipa',
          dsym: './spec/fixtures/symbols/Themoji.dSYM.zip',
          group: 'Testers1,Testers2,Testers3'
        })
      end").runner.execute(:test)
    end

    it "creates app if it was not found" do
      stub_check_app(404)
      stub_create_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(200)
      stub_add_to_group(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "handles app creation error" do
      stub_check_app(404)
      stub_create_app(500)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          group: 'Testers'
        })
      end").runner.execute(:test)
    end

    it "zips dSYM files if dsym parameter is folder" do
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_upload_build(200)
      stub_update_release_upload(200, 'committed')
      stub_get_group(200)
      stub_add_to_group(200)
      stub_get_release(200)
      stub_create_dsym_upload(200)
      stub_upload_dsym(200)
      stub_update_dsym_upload(200, "committed")

      values = Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
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
      stub_check_app(200)
      stub_create_dsym_upload(200)
      stub_upload_dsym(200)
      stub_update_dsym_upload(200, "committed")

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          upload_dsym_only: true,
          dsym: './spec/fixtures/symbols/Themoji.dSYM.zip'
        })
      end").runner.execute(:test)
    end

    it "uses DSYM_OUTPUT_PATH as default for dsym" do
      stub_check_app(200)
      stub_create_dsym_upload(200)
      stub_upload_dsym(200)
      stub_update_dsym_upload(200, "committed")

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = './spec/fixtures/symbols/Themoji.dSYM.zip'

        appcenter_upload({
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
        stub_check_app(200)
        stub_create_release_upload(401)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
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
        stub_check_app(200)
        stub_create_dsym_upload(401)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
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
      stub_check_app(200)
      stub_create_dsym_upload(200)
      stub_upload_dsym(400)
      stub_update_dsym_upload(200, 'aborted')

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
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

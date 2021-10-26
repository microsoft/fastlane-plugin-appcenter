require_relative 'appcenter_stub'
require_relative 'upload_stubs'

describe Fastlane::Actions::AppcenterUploadAction do
  describe '#run' do
    before :each do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
    end

    after :each do
      Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::APPCENTER_API_TOKEN] = nil
        Actions.lane_context[SharedValues::APPCENTER_OWNER_NAME] = nil
        Actions.lane_context[SharedValues::APPCENTER_APP_NAME] = nil
        Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = nil
        Actions.lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH] = nil
        Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] = nil
        Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = nil
        Actions.lane_context[SharedValues::GRADLE_MAPPING_TXT_OUTPUT_PATH] = nil if defined? SharedValues::GRADLE_MAPPING_TXT_OUTPUT_PATH
        Actions.lane_context[SharedValues::FL_CHANGELOG] = nil
      end").runner.execute(:test)
    end

    it "raises an error if no api token was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Testers',
            destination_type: 'group',
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
            destinations: 'Testers',
            destination_type: 'group',
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
            destinations: 'Testers',
            destination_type: 'group',
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
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Couldn't find build file at path ''")
    end

    it "raises an error if no build file was given (exception, 200)" do
      expect do
        stub_check_app_exception(200)
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Couldn't find build file at path ''")
    end

    it "raises an error if no build file was given (429, 200)" do
      expect do
        stub_check_app_429(200)
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Testers',
            destination_type: 'group'
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
            destinations: 'Testers',
            destination_type: 'group',
            apk: './nothing.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("Couldn't find build file at path './nothing.apk'")
    end

    it "raises an error if given aab was not found" do
      expect do
        stub_check_app(200)
        stub_get_destination(200, 'app', 'owner', 'store', 'Alpha')
        stub_add_to_destination(200, 'app', 'owner', 'store')
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Alpha',
            destination_type: 'store',
            aab: './nothing.aab'
          })
        end").runner.execute(:test)
      end.to raise_error("Couldn't find build file at path './nothing.aab'")
    end

    it "raises an error if given aab was not found (check app: exception, 200)" do
      expect do
        stub_check_app_exception(200)
        stub_get_destination(200, 'app', 'owner', 'store', 'Alpha')
        stub_add_to_destination(200, 'app', 'owner', 'store')
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Alpha',
            destination_type: 'store',
            aab: './nothing.aab'
          })
        end").runner.execute(:test)
      end.to raise_error("Couldn't find build file at path './nothing.aab'")
    end

    it "raises an error if given ipa was not found" do
      expect do
        stub_check_app(200)
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Testers',
            destination_type: 'group',
            ipa: './nothing.ipa'
          })
        end").runner.execute(:test)
      end.to raise_error("Couldn't find build file at path './nothing.ipa'")
    end

    it "raises an error if given ipa was not found (429, 200)" do
      expect do
        stub_check_app_429(200)
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Testers',
            destination_type: 'group',
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
            destinations: 'Testers',
            destination_type: 'group',
            apk: './spec/fixtures/appfiles/Appfile_empty'
          })
        end").runner.execute(:test)
      end.to raise_error("Only \".apk\" formats are allowed, you provided \"\"")
    end

    it "raises an error if given file has invalid extension for aab" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Testers',
            destination_type: 'group',
            aab: './spec/fixtures/appfiles/Appfile_empty'
          })
        end").runner.execute(:test)
      end.to raise_error("Only \".aab\" formats are allowed, you provided \"\"")
    end

    it "raises an error if given file has invalid extension for ipa" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Testers',
            destination_type: 'group',
            ipa: './spec/fixtures/appfiles/Appfile_empty'
          })
        end").runner.execute(:test)
      end.to raise_error("Only \".ipa\" formats are allowed, you provided \"\"")
    end

    %w(aab apk ipa file).each do |type1|
      %w(aab apk ipa file).each do |type2|
        next if type1 == type2

        ext1 = type1 == "file" ? "app" : type1
        ext2 = type2 == "file" ? "app" : type2
        it "raises an error if both #{type1} and #{type2} provided" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              appcenter_upload({
                api_token: 'xxx',
                owner_name: 'owner',
                app_name: 'app',
                destinations: 'Testers',
                destination_type: 'group',
                #{type1}: './spec/fixtures/appfiles/#{ext1}_file_empty.#{ext1}',
                #{type2}: './spec/fixtures/appfiles/#{ext2}_file_empty.#{ext2}'
              })
            end").runner.execute(:test)
          end.to raise_error("You can't use '#{type1}' and '#{type2}' options in one run")
        end
      end
    end

    it "raises an error if both aab and apk provided" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Testers',
            destination_type: 'group',
            aab: './spec/fixtures/appfiles/aab_file_empty.aab',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("You can't use 'aab' and 'apk' options in one run")
    end

    it "raises an error if both aab and ipa provided" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Testers',
            destination_type: 'group',
            ipa: './spec/fixtures/appfiles/ipa_file_empty.ipa',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("You can't use 'ipa' and 'apk' options in one run")
    end

    it "raises an error if destination type is not group or store" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            destinations: 'Testers',
            destination_type: 'random',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk'
          })
        end").runner.execute(:test)
      end.to raise_error("No or incorrect destination type given. Use 'group' or 'store'")
    end

    it "raises an error on update release upload error" do
      expect do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200)
        stub_upload_build(200)
        stub_finish_release_upload(200)
        stub_poll_for_release_id(200)
        stub_update_release_upload(500, 'uploadFinished')

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Internal Service Error, please try again later")
    end

    it "handles external service response and fails" do
      expect do
        stub_check_app(200)
        stub_create_release_upload(500)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Internal Service Error, please try again later")
    end

    it "raises an error on upload build failure" do
      expect do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200)
        stub_upload_build(500)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Upload aborted")
    end

    it "raises an error on release upload creation auth failure" do
      expect do
        stub_check_app(200)
        stub_create_release_upload(401)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Auth Error, provided invalid token")
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
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "handles failed set metadata" do
      expect do
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(501)
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Upload aborted")
    end

    it "handles set_release_upload_metadata not returning chunk size" do
      expect do
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200, "apk_file_empty.apk", "{}")

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Upload aborted")
    end

    it "handles errors in 'finish'" do
      expect do
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200)
        stub_upload_build(200)
        stub_finish_release_upload(501)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Upload aborted")
    end

    it "handles errors in 'finish' body" do
      expect do
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200)
        stub_upload_build(200)
        stub_finish_release_upload(200, "{\"error\": true}")

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Upload aborted")
    end

    it "handles errors in 'poll_for_release_id'" do
      expect do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200)
        stub_upload_build(200)
        stub_finish_release_upload(200)
        stub_update_release_upload(200, 'uploadFinished')
        stub_poll_for_release_id(status: 200, body: "{\"upload_status\":\"error\"}")

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Failed to upload release")
    end

    it "handles errors in 'poll_for_release_id' body" do
      expect do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200)
        stub_upload_build(200)
        stub_finish_release_upload(200)
        stub_update_release_upload(200, 'uploadFinished')
        stub_poll_for_release_id(501)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Failed to upload release")
    end

    it "handles invalid 'release_distinct_id' in 'poll_for_release_id' body" do
      expect do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200)
        stub_upload_build(200)
        stub_finish_release_upload(200)
        stub_update_release_upload(200, 'uploadFinished')
        stub_poll_for_release_id(status: 200, body: "{\"release_distinct_id\":\"notAnInteger\",\"upload_status\":\"readyToBePublished\"}")

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Failed to upload release")
    end

    it "handles not found distribution group" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200)
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(404)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "handles not found release" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200)
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(404)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "can use a generated changelog as release notes" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200)
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'autogenerated changelog')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::FL_CHANGELOG] = 'autogenerated changelog'

        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      expect(values[:release_notes]).to eq('autogenerated changelog')
    end

    it "clips changelog if its length is more then 5000" do
      release_notes = '_' * 6000
      read_more = '...'
      release_notes_clipped = release_notes[0, 5000 - read_more.length] + read_more

      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200)
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, release_notes_clipped)
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group',
          release_notes: '#{release_notes}'
        })
      end").runner.execute(:test)

      expect(values[:release_notes]).to eq(release_notes_clipped)
    end

    it "clips changelog and adds link in the end if its length is more then 5000" do
      release_notes = '_' * 6000
      release_notes_link = 'https://text.com'
      read_more = "...\n\n[read more](#{release_notes_link})"
      release_notes_clipped = release_notes[0, 5000 - read_more.length] + read_more

      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200)
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      # rubocop:disable Layout/LineLength
      stub_update_release(200, "______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________...\\n\\n[read more](https://text.com)")
      # rubocop:enable Layout/LineLength
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::FL_CHANGELOG] = nil

        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group',
          release_notes: '#{release_notes}',
          release_notes_link: '#{release_notes_link}'
        })
      end").runner.execute(:test)

      expect(values[:release_notes]).to eq(release_notes_clipped)
    end

    it "works with valid parameters for android" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200)
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      # Check we uploaded only 1 chunk.
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=.*}
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=1&?.*}
    end

    it "works with valid parameters for android larger file" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200)

      allow_any_instance_of(File).to receive(:each_chunk).and_yield("the first chunk").and_yield("remainder")
      stub_request(:post, "https://upload-domain.com/upload/upload_chunk/1234?token=123abc&block_number=1")
        .to_return(status: 200, body: "{\"error\": false}", headers: { 'Content-Type' => 'application/json' })
      stub_request(:post, "https://upload-domain.com/upload/upload_chunk/1234?token=123abc&block_number=2")
        .to_return(status: 200, body: "{\"error\": false}", headers: { 'Content-Type' => 'application/json' })

      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      # Check we uploaded as 2 chunks.
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=.*},
                       times: 2
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=1&?.*},
                       body: "the first chunk"
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=2&?.*},
                       body: "remainder"
    end

    it "works with retries in upload chunk" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200)

      allow_any_instance_of(File).to receive(:each_chunk).and_yield("the only chunk")
      stub_request(:post, "https://upload-domain.com/upload/upload_chunk/1234?token=123abc&block_number=1")
        .to_return(status: 500, body: "Internal server error").then
        .to_return(status: 429, body: "Too many requests").then
        .to_return(status: 200, body: "{\"error\": false}", headers: { 'Content-Type' => 'application/json' })

      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      # Check we uploaded only 1 chunk with 3 tries.
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=.*}, times: 3
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=1&?.*}, times: 3
    end

    it "fails after maximum number of retries for upload chunk" do
      expect do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200)

        allow_any_instance_of(File).to receive(:each_chunk).and_yield("the only chunk")
        stub_request(:post, "https://upload-domain.com/upload/upload_chunk/1234?token=123abc&block_number=1")
          .to_return(status: 408, body: "Timeout").then
          .to_raise(Faraday::ConnectionFailed.new("Could not connect")).then
          .to_return(status: 500, body: "Internal server error")

        stub_finish_release_upload(200)
        stub_poll_for_release_id(200)
        stub_update_release_upload(200, 'uploadFinished')
        stub_update_release(200, 'No changelog given')
        stub_get_destination(200)
        stub_add_to_destination(200)
        stub_get_release(200)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Upload aborted")

      # Check we uploaded only 1 chunk with 3 tries.
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=.*}, times: 3
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=1&?.*}, times: 3
    end

    it "fails immediately on non retryable error" do
      expect do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200)

        allow_any_instance_of(File).to receive(:each_chunk).and_yield("the only chunk")
        stub_request(:post, "https://upload-domain.com/upload/upload_chunk/1234?token=123abc&block_number=1")
          .to_return(status: 503, body: "Service unavailable").then
          .to_return(status: 403, body: "Forbidden")

        stub_finish_release_upload(200)
        stub_poll_for_release_id(200)
        stub_update_release_upload(200, 'uploadFinished')
        stub_update_release(200, 'No changelog given')
        stub_get_destination(200)
        stub_add_to_destination(200)
        stub_get_release(200)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Client error: 403: Forbidden")

      # Check we uploaded only 1 chunk with 2 tries.
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=.*}, times: 2
      assert_requested :post, %r{https://upload-domain.com/upload/upload_chunk/.*block_number=1&?.*}, times: 2
    end

    it "works with valid parameters for android app bundle" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "aab_file_empty.aab")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200, 'app', 'owner', 'store', 'Alpha')
      stub_add_to_destination(200, 'app', 'owner', 'store')
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          aab: './spec/fixtures/appfiles/aab_file_empty.aab',
          destinations: 'Alpha',
          destination_type: 'store'
        })
      end").runner.execute(:test)
    end

    it "raises an error when trying to upload an .aab to a group" do
      expect do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200, "aab_file_empty.aab")
        stub_upload_build(200)
        stub_finish_release_upload(200)
        stub_poll_for_release_id(200)
        stub_update_release_upload(200, 'uploadFinished')
        stub_update_release(200, "No changelog given")
        stub_get_destination(200)
        stub_add_to_destination(200)
        stub_get_release(200)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            aab: './spec/fixtures/appfiles/aab_file_empty.aab',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("Can't distribute .aab to groups, please use `destination_type: 'store'`")
    end

    it "works with valid parameters for a macOS .app.zip file" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "app_file_empty.app.zip")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          file: './spec/fixtures/appfiles/app_file_empty.app.zip',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    %w(dmg pkg).each do |ext|
      it "works with valid parameters for a macOS .#{ext} file" do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200, { build_version: "1.0-alpha", build_number: "1234" })
        stub_set_release_upload_metadata(200, "#{ext}_file_empty.#{ext}")
        stub_upload_build(200)
        stub_finish_release_upload(200)
        stub_poll_for_release_id(200)
        stub_update_release_upload(200, 'uploadFinished')
        stub_update_release(200, "No changelog given")
        stub_get_destination(200)
        stub_add_to_destination(200)
        stub_get_release(200)

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            file: './spec/fixtures/appfiles/#{ext}_file_empty.#{ext}',
            destinations: 'Testers',
            destination_type: 'group',
            build_number: '1234',
            version: '1.0-alpha'
          })
        end").runner.execute(:test)
      end

      %w(version build_number mandatory_update).each do |only_field|
        # NOTE: mandatory_update is used here to test case without either field
        it "raises an error when trying to upload a .#{ext} when specifying only #{only_field}" do
          expect do
            stub_poll_sleeper
            stub_check_app(200)
            stub_create_release_upload(200)
            stub_set_release_upload_metadata(200, "#{ext}_file_empty.#{ext}")
            stub_upload_build(200)
            stub_finish_release_upload(200)
            stub_poll_for_release_id(200)
            stub_update_release_upload(200, 'uploadFinished')
            stub_update_release(200, "No changelog given")
            stub_get_destination(200)
            stub_add_to_destination(200)
            stub_get_release(200)

            Fastlane::FastFile.new.parse("lane :test do
              appcenter_upload({
                api_token: 'xxx',
                owner_name: 'owner',
                app_name: 'app',
                file: './spec/fixtures/appfiles/#{ext}_file_empty.#{ext}',
                destinations: 'Testers',
                destination_type: 'group',
                #{only_field}: '123'
              })
            end").runner.execute(:test)
          end.to raise_error("Fields `version` and `build_number` must be specified to upload a .#{ext} file")
        end
      end
    end

    %w(app app.zip dmg pkg).each do |ext|
      it "raises an error when trying to upload a .#{ext} to a store" do
        expect do
          stub_poll_sleeper
          stub_check_app(200)
          stub_create_release_upload(200)
          stub_set_release_upload_metadata(200, "#{ext}_file_empty.#{ext}")
          stub_upload_build(200)
          stub_finish_release_upload(200)
          stub_poll_for_release_id(200)
          stub_update_release_upload(200, 'uploadFinished')
          stub_update_release(200, "No changelog given")
          stub_get_destination(200, 'app', 'owner', 'store', 'Alpha')
          stub_add_to_destination(200, 'app', 'owner', 'store')
          stub_get_release(200)

          Fastlane::FastFile.new.parse("lane :test do
            appcenter_upload({
              api_token: 'xxx',
              owner_name: 'owner',
              app_name: 'app',
              file: './spec/fixtures/appfiles/#{ext}_file_empty.#{ext}',
              destinations: 'Alpha',
              destination_type: 'store'
            })
          end").runner.execute(:test)
        end.to raise_error("Can't distribute .#{ext} to stores, please use `destination_type: 'group'`")
      end
    end

    it "uses APPCENTER_API_TOKEN as default for api_token" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::APPCENTER_API_TOKEN] = 'shared-value-token'

        appcenter_upload({
          owner_name: 'owner',
          app_name: 'app',
          ipa: './spec/fixtures/appfiles/ipa_file_empty.ipa',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      expect(values[:api_token]).to eq('shared-value-token')
    end

    it "uses APPCENTER_OWNER_NAME as default for owner_name" do
      stub_poll_sleeper
      stub_check_app(200, 'app', 'shared-value-owner')
      stub_create_release_upload(200, nil, 'app', 'shared-value-owner')
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200, "app", "shared-value-owner")
      stub_update_release_upload(200, 'uploadFinished', 'app', 'shared-value-owner')
      stub_update_release(200, 'No changelog given', 'app', 'shared-value-owner')
      stub_get_destination(200, 'app', 'shared-value-owner')
      stub_add_to_destination(200, 'app', 'shared-value-owner')
      stub_get_release(200, 'app', 'shared-value-owner')

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::APPCENTER_OWNER_NAME] = 'shared-value-owner'

        appcenter_upload({
          api_token: 'xxx',
          app_name: 'app',
          ipa: './spec/fixtures/appfiles/ipa_file_empty.ipa',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      expect(values[:owner_name]).to eq('shared-value-owner')
    end

    it "uses APPCENTER_APP_NAME as default for app_name" do
      stub_poll_sleeper
      stub_check_app(200, 'shared-value-app')
      stub_create_release_upload(200, nil, 'shared-value-app')
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200, 'shared-value-app')
      stub_update_release_upload(200, 'uploadFinished', 'shared-value-app')
      stub_update_release(200, 'No changelog given', 'shared-value-app')
      stub_get_destination(200, 'shared-value-app')
      stub_add_to_destination(200, 'shared-value-app')
      stub_get_release(200, 'shared-value-app')

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::APPCENTER_APP_NAME] = 'shared-value-app'

        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          ipa: './spec/fixtures/appfiles/ipa_file_empty.ipa',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      expect(values[:app_name]).to eq('shared-value-app')
    end

    it "uses GRADLE_APK_OUTPUT_PATH as default for apk" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "apk_file_empty.apk")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] = './spec/fixtures/appfiles/apk_file_empty.apk'

        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      expect(values[:apk]).to eq('./spec/fixtures/appfiles/apk_file_empty.apk')
    end

    if defined? Fastlane::Actions::SharedValues::GRADLE_MAPPING_TXT_OUTPUT_PATH
      it "uses GRADLE_MAPPING_TXT_OUTPUT_PATH as default for mapping" do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200, "apk_file_empty.apk")
        stub_upload_build(200)
        stub_finish_release_upload(200)
        stub_poll_for_release_id(200)
        stub_update_release_upload(200, 'uploadFinished')
        stub_update_release(200, "No changelog given")
        stub_get_destination(200)
        stub_add_to_destination(200)
        stub_get_release(200)
        stub_create_mapping_upload(200, "1.0.0", "3")
        stub_upload_mapping(200)
        stub_update_mapping_upload(200, "committed")

        values = Fastlane::FastFile.new.parse("lane :test do
          Actions.lane_context[SharedValues::GRADLE_MAPPING_TXT_OUTPUT_PATH] = './spec/fixtures/symbols/mapping.txt'

          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)

        expect(values[:mapping]).to eq('./spec/fixtures/symbols/mapping.txt')
      end
    else
      it "skips test for undefined GRADLE_MAPPING_TXT_OUTPUT_PATH" do
        # do nothing
      end
    end

    it "uses GRADLE_AAB_OUTPUT_PATH as default for aab" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "aab_file_empty.aab")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200, 'app', 'owner', 'store', 'Alpha')
      stub_add_to_destination(200, 'app', 'owner', 'store')
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH] = './spec/fixtures/appfiles/aab_file_empty.aab'

        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          destinations: 'Alpha',
          destination_type: 'store'
        })
      end").runner.execute(:test)

      expect(values[:aab]).to eq('./spec/fixtures/appfiles/aab_file_empty.aab')
    end

    it "uses IPA_OUTPUT_PATH as default for ipa" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = './spec/fixtures/appfiles/ipa_file_empty.ipa'

        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      expect(values[:ipa]).to eq('./spec/fixtures/appfiles/ipa_file_empty.ipa')
    end

    it "uses file parameter over default IPA_OUTPUT_PATH and doesn't raise error" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      values = Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = 'raise_error_if_used.ipa'

        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          file: './spec/fixtures/appfiles/ipa_file_empty.ipa',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      expect(values[:file]).to eq('./spec/fixtures/appfiles/ipa_file_empty.ipa')
    end

    it "works with valid parameters for ios" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
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
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "uses proper api for mandatory release" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200, 'app', 'owner', 'group', mandatory_update: true, notify_testers: false)
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
          destinations: 'Testers',
          destination_type: 'group',
          mandatory_update: true
        })
      end").runner.execute(:test)
    end

    it "uses proper api for release with email notification parameter" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200, 'app', 'owner', 'group', mandatory_update: false, notify_testers: true)
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
          destinations: 'Testers',
          destination_type: 'group',
          notify_testers: true
        })
      end").runner.execute(:test)
    end

    it "uses proper api for mandatory release with email notification parameter" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200, 'app', 'owner', 'group', mandatory_update: true, notify_testers: true)
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
          destinations: 'Testers',
          destination_type: 'group',
          mandatory_update: true,
          notify_testers: true
        })
      end").runner.execute(:test)
    end

    describe "uploading a macOS app" do
      describe "not zipped" do
        it "works with valid parameters" do
          stub_poll_sleeper
          stub_check_app(200)
          stub_create_release_upload(200)
          stub_set_release_upload_metadata(200, "app_file_empty.app.zip")
          stub_upload_build(200)
          stub_finish_release_upload(200)
          stub_poll_for_release_id(200)
          stub_update_release_upload(200, 'uploadFinished')
          stub_update_release(200, "No changelog given")
          stub_get_destination(200)
          stub_add_to_destination(200)
          stub_get_release(200)
          stub_create_dsym_upload(200)
          stub_upload_dsym(200)
          stub_update_dsym_upload(200, "committed")

          allow(Fastlane::UI).to receive(:interactive?).and_return(false)
          allow(Fastlane::Actions::ZipAction).to receive(:run).and_return(File.expand_path('./spec/fixtures/appfiles/app_file_empty.app.zip'))
          expect(File).to receive(:delete).with('./spec/fixtures/appfiles/app_file_empty.app.zip')
          expect(Fastlane::Actions::ZipAction).to receive(:run)
            .with({
              path: './spec/fixtures/appfiles/app_file_empty.app',
              output_path: './spec/fixtures/appfiles/app_file_empty.app.zip',
              symlinks: true
            })

          Fastlane::FastFile.new.parse("lane :test do
            appcenter_upload({
              api_token: 'xxx',
              owner_name: 'owner',
              app_name: 'app',
              file: './spec/fixtures/appfiles/app_file_empty.app',
              dsym: './spec/fixtures/symbols/Themoji.dSYM.zip',
              destinations: 'Testers'
            })
          end").runner.execute(:test)
        end
      end

      describe "zipped" do
        it "works with valid parameters" do
          stub_poll_sleeper
          stub_check_app(200)
          stub_create_release_upload(200)
          stub_set_release_upload_metadata(200, "app_file_empty.app.zip")
          stub_upload_build(200)
          stub_finish_release_upload(200)
          stub_poll_for_release_id(200)
          stub_update_release_upload(200, 'uploadFinished')
          stub_update_release(200, 'No changelog given')
          stub_get_destination(200)
          stub_add_to_destination(200)
          stub_get_release(200)
          stub_create_dsym_upload(200)
          stub_upload_dsym(200)
          stub_update_dsym_upload(200, "committed")

          expect(Fastlane::Actions::ZipAction).not_to receive(:run)

          Fastlane::FastFile.new.parse("lane :test do
            appcenter_upload({
              api_token: 'xxx',
              owner_name: 'owner',
              app_name: 'app',
              file: './spec/fixtures/appfiles/app_file_empty.app.zip',
              dsym: './spec/fixtures/symbols/Themoji.dSYM.zip',
              destinations: 'Testers'
            })
          end").runner.execute(:test)
        end
      end

      describe "Sparkle Feed" do
        it "handles dsa_signature" do
          stub_poll_sleeper
          stub_check_app(200)
          stub_create_release_upload(200)
          stub_set_release_upload_metadata(200, "app_file_empty.app.zip")
          stub_upload_build(200)
          stub_finish_release_upload(200)
          stub_poll_for_release_id(200)
          stub_update_release_upload(200, 'uploadFinished')
          stub_update_release(200, 'No changelog given')
          stub_update_release_metadata(200)
          stub_get_destination(200)
          stub_add_to_destination(200)
          stub_get_release(200)

          expect(Fastlane::Actions::ZipAction).not_to receive(:run)

          Fastlane::FastFile.new.parse("lane :test do
            appcenter_upload({
              api_token: 'xxx',
              owner_name: 'owner',
              app_name: 'app',
              file: './spec/fixtures/appfiles/app_file_empty.app.zip',
              destinations: 'Testers',
              dsa_signature: 'test_signature',
              ed_signature: 'test_eddsa_signature'
            })
          end").runner.execute(:test)
        end
      end
    end

    it "adds to all provided groups" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200, 'app', 'owner', 'group', 'Testers1')
      stub_get_destination(200, 'app', 'owner', 'group', 'Testers2')
      stub_get_destination(200, 'app', 'owner', 'group', 'Testers3')
      stub_add_to_destination(200)
      stub_add_to_destination(200)
      stub_add_to_destination(200)
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
          destinations: 'Testers1,Testers2,Testers3',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "encodes group names" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200, 'app', 'owner', 'group', 'Testers%201')
      stub_get_destination(200, 'app', 'owner', 'group', 'Testers%202')
      stub_get_destination(200, 'app', 'owner', 'group', 'Testers%203')
      stub_add_to_destination(200)
      stub_add_to_destination(200)
      stub_add_to_destination(200)
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
          destinations: 'Testers 1,Testers 2,Testers 3',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "can release to store" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200, 'app', 'owner', 'store')
      stub_add_to_destination(200, 'app', 'owner', 'store')
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
          destinations: 'Testers',
          destination_type: 'store'
        })
      end").runner.execute(:test)
    end

    it "creates app if it was not found" do
      stub_poll_sleeper
      stub_check_app(404)
      stub_create_app(200, "app", "app", "Android", "Java")
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "apk_file_empty.apk")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "creates app if it was not found with specified os, platform and display_name" do
      stub_poll_sleeper
      stub_check_app(404)
      stub_create_app(200, "app", "App Name", "Android", "Java")
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "apk_file_empty.apk")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          app_display_name: 'App Name',
          app_os: 'Android',
          app_platform: 'Java',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "creates app if it was not found with specified macOS that supports only one platform" do
      stub_poll_sleeper
      stub_check_app(404)
      stub_create_app(200, "app", "App Name", "macOS", "Objective-C-Swift")
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "app.zip_file_empty.app.zip")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          app_display_name: 'App Name',
          app_os: 'macOS',
          file: './spec/fixtures/appfiles/app.zip_file_empty.app.zip',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "creates app if it was not found with specified macOS that supports only one platform (create app: 429, 200)" do
      stub_poll_sleeper
      stub_check_app(404)
      stub_create_app_429(200, "app", "App Name", "macOS", "Objective-C-Swift")
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "app.zip_file_empty.app.zip")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          app_display_name: 'App Name',
          app_os: 'macOS',
          file: './spec/fixtures/appfiles/app.zip_file_empty.app.zip',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "creates app when app_os is Windows and selects the app_platform" do
      stub_poll_sleeper
      stub_check_app(404)
      stub_create_app(200, "app", "App Name", "Windows", "UWP")
      stub_create_release_upload(200, { build_version: "1.0" })
      stub_set_release_upload_metadata(200, "zip_file_empty.zip")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          app_display_name: 'App Name',
          app_os: 'Windows',
          file: './spec/fixtures/appfiles/zip_file_empty.zip',
          version: '1.0',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "creates app when app_os is Windows and selects the app_platform (create app: exception, 200)" do
      stub_poll_sleeper
      stub_check_app(404)
      stub_create_app_exception(200, "app", "App Name", "Windows", "UWP")
      stub_create_release_upload(200, { build_version: "1.0" })
      stub_set_release_upload_metadata(200, "zip_file_empty.zip")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, 'No changelog given')
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          app_display_name: 'App Name',
          app_os: 'Windows',
          file: './spec/fixtures/appfiles/zip_file_empty.zip',
          version: '1.0',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "creates app in organization if it was not found with specified os, platform and display_name" do
      stub_poll_sleeper
      stub_check_app(404)
      stub_create_app(200, "app", "App Name", "Android", "Java", "organization", "owner")
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "apk_file_empty.apk")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)
      stub_fetch_distribution_groups(owner_name: 'owner', app_name: 'app')
      stub_add_new_app_to_distribution

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_type: 'organization',
          owner_name: 'owner',
          app_name: 'app',
          app_display_name: 'App Name',
          app_os: 'Android',
          app_platform: 'Java',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group'
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
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "handles app creation error in org" do
      stub_check_app(404)
      stub_create_app(500, "app", "app", "Android", "Java", "organization", "owner")

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_type: 'organization',
          owner_name: 'owner',
          app_name: 'app',
          app_os: 'Android',
          app_platform: 'Java',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "allows to send android mappings" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "apk_file_empty.apk")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)
      stub_create_mapping_upload(200, "1.0.0", "3")
      stub_upload_mapping(200)
      stub_update_mapping_upload(200, "committed")

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          mapping: './spec/fixtures/symbols/mapping.txt',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "allows to send android mappings with custom name" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "apk_file_empty.apk")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)
      stub_create_mapping_upload(200, "1.0.0", "3", "renamed-mapping.txt")
      stub_upload_mapping(200)
      stub_update_mapping_upload(200, "committed")

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          mapping: './spec/fixtures/symbols/renamed-mapping.txt',
          destinations: 'Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "allows to send only android mappings" do
      stub_check_app(200)
      stub_create_mapping_upload(200, "1.0.0", "3", "renamed-mapping.txt")
      stub_upload_mapping(200)
      stub_update_mapping_upload(200, "committed")

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          upload_mapping_only: true,
          mapping: './spec/fixtures/symbols/renamed-mapping.txt',
          build_number: '3',
          version: '1.0.0'
        })
      end").runner.execute(:test)
    end

    it "zips dSYM files if dsym parameter is folder" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
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
          destinations: 'Testers',
          destination_type: 'group'
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

    it "rejects dsym for a non-Apple app file" do
      expect do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200, "apk_file_empty.apk")
        stub_upload_build(200)
        stub_finish_release_upload(200)
        stub_poll_for_release_id(200)
        stub_update_release_upload(200, 'uploadFinished')
        stub_update_release(200, "No changelog given")
        stub_get_destination(200)
        stub_add_to_destination(200)
        stub_get_release(200)
        stub_create_dsym_upload(200)
        stub_upload_dsym(200)
        stub_update_dsym_upload(200, "committed")

        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            file: './spec/fixtures/appfiles/apk_file_empty.apk',
            dsym: './spec/fixtures/symbols/Themoji.dSYM.zip',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error("dsym parameter can only be used with Apple builds (ios, mac)")
    end

    it "allows to upload build only even if dsym provided when upload_build_only is true" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          ipa: './spec/fixtures/appfiles/ipa_file_empty.ipa',
          dsym: './spec/fixtures/symbols/Themoji.dSYM.zip',
          destinations: 'Testers',
          destination_type: 'group',
          upload_build_only: true
        })
      end").runner.execute(:test)
    end

    it "allows to upload build only even if mapping provided when upload_build_only is true" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "apk_file_empty.apk")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200)
      stub_add_to_destination(200)
      stub_get_release(200)

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_name: 'owner',
          app_name: 'app',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          mapping: './spec/fixtures/symbols/mapping.txt',
          destinations: 'Testers',
          destination_type: 'group',
          upload_build_only: true
        })
      end").runner.execute(:test)
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
            destinations: 'Testers',
            destination_type: 'group'
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

    it "asterik as destination" do
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_fetch_distribution_groups(owner_name: 'owner', app_name: 'app')
      stub_get_destination(200, 'app', 'owner', 'group', 'Collaborators')
      stub_get_destination(200, 'app', 'owner', 'group', 'test-group-1')
      stub_get_destination(200, 'app', 'owner', 'group', 'test group 2')
      stub_add_to_destination(200)
      stub_add_to_destination(200)
      stub_add_to_destination(200)
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
          destinations: '*',
          destination_type: 'group'
        })
      end").runner.execute(:test)
    end

    it "asterik as destination verify that destinations are retrieved" do
      collaborators = 'Collaborators'
      test_group_1 = 'Test-Group-1'
      test_group_2 = 'Test-Group-2'
      stub_poll_sleeper
      stub_check_app(200)
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_fetch_distribution_groups(owner_name: 'owner', app_name: 'app', groups: [collaborators, test_group_1, test_group_2])
      collaborator_req = stub_get_destination(200, 'app', 'owner', 'group', collaborators)
      test_group_1_req = stub_get_destination(200, 'app', 'owner', 'group', test_group_1)
      test_group_2_req = stub_get_destination(200, 'app', 'owner', 'group', test_group_2)
      stub_add_to_destination(200)
      stub_add_to_destination(200)
      stub_add_to_destination(200)
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
          destinations: '*',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      assert_requested(collaborator_req)
      assert_requested(test_group_1_req)
      assert_requested(test_group_2_req)
    end

    it "asterik as destination for store type" do
      expect do
        stub_poll_sleeper
        stub_check_app(200)
        stub_create_release_upload(200)
        stub_set_release_upload_metadata(200, "ipa_file_empty.ipa")
        stub_upload_build(200)
        stub_finish_release_upload(200)
        stub_poll_for_release_id(200)
        stub_update_release_upload(200, 'uploadFinished')
        stub_update_release(200, "No changelog given")
        stub_fetch_distribution_groups(owner_name: 'owner', app_name: 'app')
        stub_get_destination(200, 'app', 'owner', 'group', 'Collaborators')
        stub_get_destination(200, 'app', 'owner', 'group', 'test-group-1')
        stub_get_destination(200, 'app', 'owner', 'group', 'test group 2')
        stub_add_to_destination(200)
        stub_add_to_destination(200)
        stub_add_to_destination(200)
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
            destinations: '*',
            destination_type: 'store'
          })
        end").runner.execute(:test)
      end.to raise_error("The combination of `destinations: '*'` and `destination_type: 'store'` is invalid, please use `destination_type: 'group'` or explicitly specify the destinations")
    end

    it "Handles invalid app name error" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'appname with space',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group'
          })
        end").runner.execute(:test)
      end.to raise_error(/Please ensure no special characters or spaces in the app_name./)
    end

    it "Handles conflicting options of upload_build_only and upload_dysm_only" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          appcenter_upload({
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'appname',
            apk: './spec/fixtures/appfiles/apk_file_empty.apk',
            destinations: 'Testers',
            destination_type: 'group',
            upload_build_only: true,
            upload_dsym_only: true
          })
        end").runner.execute(:test)
      end.to raise_error(/can't use 'upload_build_only' and 'upload_dsym_only' options in one run/)
    end

    it 'Skips adding app to distribution group if already added' do
      stub_poll_sleeper
      stub_check_app(404)
      stub_create_app(200, "app", "App Name", "Android", "Java", "organization", "owner")
      stub_create_release_upload(200)
      stub_set_release_upload_metadata(200, "apk_file_empty.apk")
      stub_upload_build(200)
      stub_finish_release_upload(200)
      stub_poll_for_release_id(200)
      stub_update_release_upload(200, 'uploadFinished')
      stub_update_release(200, "No changelog given")
      stub_get_destination(200, app_name = "app", owner_name = "owner", destination_type = "group", destination_name = "Testers")
      stub_get_destination(200, app_name = "app", owner_name = "owner", destination_type = "group", destination_name = "test-group-1")
      stub_add_to_destination(200)
      stub_get_release(200)
      stub_fetch_distribution_groups(owner_name: 'owner', app_name: 'app')

      should_be_called = stub_add_new_app_to_distribution(destination_name: 'Testers')
      should_not_be_called = stub_add_new_app_to_distribution(destination_name: 'test-group-1')

      Fastlane::FastFile.new.parse("lane :test do
        appcenter_upload({
          api_token: 'xxx',
          owner_type: 'organization',
          owner_name: 'owner',
          app_name: 'app',
          app_display_name: 'App Name',
          app_os: 'Android',
          app_platform: 'Java',
          apk: './spec/fixtures/appfiles/apk_file_empty.apk',
          destinations: 'test-group-1,Testers',
          destination_type: 'group'
        })
      end").runner.execute(:test)

      assert_requested(should_be_called)
      assert_not_requested(should_not_be_called)
    end
  end
end

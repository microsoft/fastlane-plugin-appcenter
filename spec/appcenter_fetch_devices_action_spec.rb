require_relative 'appcenter_stub'

def allow_devices_file(devices_file)
  allow(CSV).to receive(:open)
    .with(devices_file, 'w',
          write_headers: true,
          headers: ['Device ID', 'Device Name'],
          col_sep: "\t")
    .and_yield(CSV.open('./spec/fixtures/devicesfiles/devices.txt'))

  allow(CSV).to receive(:parse).and_return('')
end

describe Fastlane::Actions::AppcenterFetchDevicesAction do
  describe '#run' do
    after :each do
      Fastlane::FastFile.new.parse("lane :test do
        Actions.lane_context[SharedValues::APPCENTER_API_TOKEN] = nil
        Actions.lane_context[SharedValues::APPCENTER_OWNER_NAME] = nil
        Actions.lane_context[SharedValues::APPCENTER_APP_NAME] = nil
      end").runner.execute(:test)
    end

    it "raises an error if no api token was given" do
      expect do
        Fastlane::FastFile.new.parse("
        lane :test do
          appcenter_fetch_devices(
            owner_name: 'owner',
            app_name: 'app',
            devices_file: 'test.txt'
          )
        end").runner.execute(:test)
      end.to raise_error("No API token for App Center given, pass using `api_token: 'token'`")
    end

    it "raises an error if no owner name was given" do
      expect do
        Fastlane::FastFile.new.parse("
        lane :test do
          appcenter_fetch_devices(
            api_token: 'xxx',
            app_name: 'app',
            devices_file: 'test.txt'
          )
        end").runner.execute(:test)
      end.to raise_error("No Owner name for App Center given, pass using `owner_name: 'name'`")
    end

    it "raises an error if no app name was given" do
      expect do
        Fastlane::FastFile.new.parse("
        lane :test do
          appcenter_fetch_devices(
            api_token: 'xxx',
            owner_name: 'owner',
            devices_file: 'test.txt'
          )
        end").runner.execute(:test)
      end.to raise_error("No App name given, pass using `app_name: 'app name'`")
    end

    context "with valid token, owner name, app name, and default group" do
      before(:each) do
        stub_fetch_devices(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'Collaborators'
        )
      end

      it "writes a devices file with a default name" do
        allow_devices_file('devices.txt')

        Fastlane::FastFile.new.parse("
          lane :test do
            appcenter_fetch_devices(
              api_token: 'xxx',
              owner_name: 'owner',
              app_name: 'app'
            )
          end").runner.execute(:test)
      end
    end

    context "with valid token, owner name, app name, default group, 429 errors and exceptions" do
      def default_group
        Fastlane::FastFile.new.parse("
          lane :test do
            appcenter_fetch_devices(
              api_token: 'xxx',
              owner_name: 'owner',
              app_name: 'app'
            )
          end").runner.execute(:test)
      end

      it "writes a devices file with a default name (429, 200)" do
        allow_devices_file('devices.txt')
        stub_fetch_devices_chain(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'Collaborators',
          response_codes: [429, 200]
        )

        default_group
      end

      it "writes a devices file with a default name (429, 429, 200)" do
        allow_devices_file('devices.txt')
        stub_fetch_devices_chain(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'Collaborators',
          response_codes: [429, 429, 200]
        )

        default_group
      end

      it "writes a devices file with a default name (exception, 200)" do
        allow_devices_file('devices.txt')
        stub_fetch_devices_chain(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'Collaborators',
          response_codes: [-1, 200]
        )

        default_group
      end

      it "writes a devices file with a default name (exception, 429, 200)" do
        allow_devices_file('devices.txt')
        stub_fetch_devices_chain(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'Collaborators',
          response_codes: [-1, 429, 200]
        )

        default_group
      end

      it "writes a devices file with a default name (429, exception, 200)" do
        allow_devices_file('devices.txt')
        stub_fetch_devices_chain(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'Collaborators',
          response_codes: [429, -1, 200]
        )

        default_group
      end
    end

    context "with valid token, owner name, app name, and all groups" do
      before(:each) do
        stub_fetch_distribution_groups(
          owner_name: 'owner',
          app_name: 'app'
        )
        stub_fetch_devices(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'Collaborators'
        )
        stub_fetch_devices(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'test-group-1'
        )
        stub_fetch_devices(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'test group 2'
        )
      end

      it "writes a devices file with a default name" do
        allow_devices_file('devices.txt')

        Fastlane::FastFile.new.parse("
          lane :test do
            appcenter_fetch_devices(
              api_token: 'xxx',
              owner_name: 'owner',
              app_name: 'app',
              destinations: '*'
            )
          end").runner.execute(:test)
      end
    end

    context "with valid token, owner name, app name, all groups, 429 errors and exceptions" do
      it "writes a devices file with a default name" do
        stub_fetch_distribution_groups_chain(
          owner_name: 'owner',
          app_name: 'app',
          response_codes: [429, -1, 200]
        )
        stub_fetch_devices(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'Collaborators'
        )
        stub_fetch_devices_chain(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'test-group-1',
          response_codes: [-1, -1, 200]
        )
        stub_fetch_devices_chain(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'test group 2',
          response_codes: [429, 429, 200]
        )

        allow_devices_file('devices.txt')

        Fastlane::FastFile.new.parse("
          lane :test do
            appcenter_fetch_devices(
              api_token: 'xxx',
              owner_name: 'owner',
              app_name: 'app',
              destinations: '*'
            )
          end").runner.execute(:test)
      end
    end

    context "with valid token, owner name, and app name" do
      before(:each) do
        stub_fetch_distribution_groups(
          owner_name: 'owner',
          app_name: 'app'
        )
        stub_fetch_devices(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'Collaborators'
        )
        stub_fetch_devices(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'test-group-1'
        )
        stub_fetch_devices(
          owner_name: 'owner',
          app_name: 'app',
          distribution_group: 'test group 2'
        )
      end

      it "prints an important message when devices file extension is not .txt" do
        expect(Fastlane::UI).to receive(:important).with("Important: Devices file is ./test.abc. If you plan to upload this file to Apple Developer Center, the file must have the .txt extension")

        Fastlane::FastFile.new.parse("
        lane :test do
          appcenter_fetch_devices(
            api_token: 'xxx',
            owner_name: 'owner',
            app_name: 'app',
            devices_file: './test.abc',
            destinations: '*'
          )
        end").runner.execute(:test)

        File.delete('./fastlane/test.abc')
      end

      it "writes a devices file with a default name" do
        allow_devices_file('devices.txt')

        Fastlane::FastFile.new.parse("
          lane :test do
            appcenter_fetch_devices(
              api_token: 'xxx',
              owner_name: 'owner',
              app_name: 'app',
              destinations: '*'
            )
          end").runner.execute(:test)
      end

      it "writes a devices file with a custom name" do
        allow_devices_file('custom-name.txt')

        Fastlane::FastFile.new.parse("
          lane :test do
            appcenter_fetch_devices(
              api_token: 'xxx',
              owner_name: 'owner',
              app_name: 'app',
              devices_file: 'custom-name.txt',
              destinations: '*'
            )
          end").runner.execute(:test)
      end

      it "supports only the iOS platform" do
        expect(Fastlane::Actions::AppcenterFetchDevicesAction.is_supported?(:ios)).to be(true)
        expect(Fastlane::Actions::AppcenterFetchDevicesAction.is_supported?(:android)).to be(false)
        expect(Fastlane::Actions::AppcenterFetchDevicesAction.is_supported?(:mac)).to be(false)
      end
    end
  end
end

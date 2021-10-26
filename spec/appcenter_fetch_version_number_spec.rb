require_relative 'fetch_version_number_stubs'

describe Fastlane::Actions::AppcenterFetchVersionNumberAction do
  describe '#run' do
    before :each do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
    end

    context "check the correct errors are raised" do
      it 'raises an error when no api token is given' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              owner_name: 'owner-name',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end.to raise_error("No API token for App Center given, pass using `api_token: 'token'`")
      end

      it 'raises an error when the app name does not exist for an owner/account' do
        stub_get_releases_forbidden(403)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end.to raise_error("No versions found for 'App-Name' owned by owner-name")
      end

      it 'raises an error when the owner/account name or API key are incorrect' do
        stub_get_releases_not_found(404)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end.to raise_error("No versions found for 'App-Name' owned by owner-name")
      end

      it 'raises an error when there are no releases for an app' do
        stub_get_releases_empty_success(200)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name-no-versions'
            )
          end").runner.execute(:test)
        end.to raise_error("This app has no releases yet")
      end

      it "raises an error when there are no releases for a provided version of an app" do
        stub_get_releases_success(200)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name',
              version: '2.0.0'
            )
          end").runner.execute(:test)
        end.to raise_error("The provided version (2.0.0) has no releases yet")
      end
    end

    context "check the correct errors are raised, requests with 429 error end exceptions" do
      it '429 error and raises an error when no api token is given' do
        stub_get_releases_429
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              owner_name: 'owner-name',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end.to raise_error("No API token for App Center given, pass using `api_token: 'token'`")
      end

      it 'exception and raises an error when no api token is given' do
        stub_get_releases_exception
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              owner_name: 'owner-name',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end.to raise_error("No API token for App Center given, pass using `api_token: 'token'`")
      end

      it "429 and raises an error when there are no releases for a provided version of an app" do
        stub_get_releases_429
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name',
              version: '2.0.0'
            )
          end").runner.execute(:test)
        end.to raise_error("The provided version (2.0.0) has no releases yet")
      end

      it "exception and raises an error when there are no releases for a provided version of an app" do
        stub_get_releases_exception
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name',
              version: '2.0.0'
            )
          end").runner.execute(:test)
        end.to raise_error("The provided version (2.0.0) has no releases yet")
      end
    end

    context "when no errors are expected" do
      let(:app) do
        {
        "display_name" => "My App Name",
            "name" => 'App-Name',
            "owner" => {
              "display_name" => 'Owner Name',
              "email" => 'test@example.com',
              "name" => 'owner-name'
            }
      }
      end

      before :each do
        allow(Fastlane::Actions::AppcenterFetchVersionNumberAction).to receive(:prompt_for_apps).and_return([app])
        stub_get_apps_success(200)
        stub_get_releases_success(200)
      end

      context "with a valid token, owner name, and app name" do
        let(:version) do
          version = Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end

        it 'returns the correct version number' do
          puts version
          expect(version["id"]).to eq(7)
          expect(version["version"]).to eq("1.0.4")
          expect(version["build_number"]).to eq("1.0.4.105")
        end
      end

      context "with provided version number and a valid token, owner name, and app name" do
        let(:version) do
          version = Fastlane::FastFile.new.parse("lane :test do
            appcenter_fetch_version_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name',
              version: '1.0.1'
            )
          end").runner.execute(:test)
        end

        it "returns the correct version and build numbers" do
          puts version
          expect(version["id"]).to eq(5)
          expect(version["version"]).to eq("1.0.1")
          expect(version["build_number"]).to eq("1.0.1.102")
        end
      end
    end
  end
end

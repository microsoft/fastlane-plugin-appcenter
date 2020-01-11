def stub_get_releases_success(status)
  success_json = JSON.parse(File.read("spec/fixtures/releases/valid_release_response.json"))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/owner-name/App-Name/releases")
    .to_return(status: status, body: success_json.to_json, headers: { 'Content-Type' => 'application/json' })
end

def stub_get_releases_empty_success(status)
  success_json = JSON.parse(File.read("spec/fixtures/releases/valid_release_empty_response.json"))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/owner-name/App-Name-no-versions/releases")
    .to_return(status: status, body: success_json.to_json, headers: { 'Content-Type' => 'application/json' })
end

def stub_get_releases_not_found(status)
  not_found_json = JSON.parse(File.read("spec/fixtures/releases/not_found.json"))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/owner-name/App-Name/releases")
    .to_return(status: status, body: not_found_json.to_json, headers: { 'Content-Type' => 'application/json' })
end

def stub_get_releases_forbidden(status)
  forbidden_json = JSON.parse(File.read("spec/fixtures/releases/forbidden.json"))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/owner-name/App-Name/releases")
    .to_return(status: status, body: forbidden_json.to_json, headers: { 'Content-Type' => 'application/json' })
end

def stub_get_apps_success(status)
  success_json = JSON.parse(File.read("spec/fixtures/apps/valid_apps_response.json"))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps")
    .to_return(status: status, body: success_json.to_json, headers: { 'Content-Type' => 'application/json' })
end

describe Fastlane::Actions::AppcenterFetchVersionNumberAction do
  describe '#run' do
    before :each do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
    end

    context 'when no api token is given' do
      it 'raises an error' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            latest_appcenter_build_number(
              owner_name: 'owner-name',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end.to raise_error("No API token for AppCenter given, pass using `api_token: 'token'`")
      end
    end

    context 'when the app does not exist for a given owner/API Key' do
      it 'raises an error' do
        stub_get_apps_success(200)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            latest_appcenter_build_number(
              api_token: '1234',
              app_name: 'App-Name-Does-Not-Exist'
            )
          end").runner.execute(:test)
        end.to raise_error("No app 'App-Name-Does-Not-Exist' found for owner ")
      end
    end

    context 'when the app name contains spaces' do
      it 'raises an error' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            latest_appcenter_build_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App Name'
            )
          end").runner.execute(:test)
        end.to raise_error("The `app_name` ('App Name') cannot contains spaces and must only contain alpha numeric characters and dashes")
      end
    end

    context 'when the app name contains special characters' do
      it 'raises an error' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            latest_appcenter_build_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name!@£$'
            )
          end").runner.execute(:test)
        end.to raise_error("The `app_name` ('App-Name!@£$') cannot contains spaces and must only contain alpha numeric characters and dashes")
      end
    end

    context 'when the owner name contains spaces' do
      it 'raises an error' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            latest_appcenter_build_number(
              api_token: '1234',
              owner_name: 'owner name',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end.to raise_error("The `owner_name` ('owner name') cannot contains spaces and must only contain lowercased alpha numeric characters and dashes")
      end
    end

    context 'when the owner name contains special characters' do
      it 'raises an error' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            latest_appcenter_build_number(
              api_token: '1234',
              owner_name: '**/Owner name!!',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end.to raise_error("The `owner_name` ('**/Owner name!!') cannot contains spaces and must only contain lowercased alpha numeric characters and dashes")
      end
    end

    context 'when the app name does not exist for an owner/account' do
      it 'raises an error' do
        stub_get_releases_forbidden(403)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            latest_appcenter_build_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end.to raise_error("API Key not valid for 'owner-name'. This will be because either the API Key or the `owner_name` are incorrect")
      end
    end

    context 'when the owner/account name or API key are incorrect' do
      it 'raises an error' do
        stub_get_releases_not_found(404)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            latest_appcenter_build_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name'
            )
          end").runner.execute(:test)
        end.to raise_error("No app or owner found with `app_name`: 'App-Name' and `owner_name`: 'owner-name'")
      end
    end

    context 'when the no app versions exist' do
      it 'raises an error' do
        stub_get_releases_empty_success(200)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            latest_appcenter_build_number(
              api_token: '1234',
              owner_name: 'owner-name',
              app_name: 'App-Name-no-versions'
            )
          end").runner.execute(:test)
        end.to raise_error("The app has no versions yet")
      end
    end

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

    context 'when no app name or owner/account are set' do
      let(:build_number) do
        build_number = Fastlane::FastFile.new.parse("lane :test do
          latest_appcenter_build_number(
            api_token: '1234'
          )
        end").runner.execute(:test)
      end

      before do
        allow(Fastlane::Actions::LatestAppcenterBuildNumberAction).to receive(:prompt_for_apps).and_return([app])
        stub_get_apps_success(200)
        stub_get_releases_success(200)
      end

      it 'prompts for an owner/account and app name' do
        allow(Fastlane::Actions::LatestAppcenterBuildNumberAction).to receive(:gets).and_return("1\n")
        expect(build_number).to eq('1.0.4.105')
      end
    end

    context 'when no app name is set' do
      let(:build_number) do
        build_number = Fastlane::FastFile.new.parse("lane :test do
          latest_appcenter_build_number(
            api_token: '1234',
            owner_name: 'owner-name'
          )
        end").runner.execute(:test)
      end

      before do
        allow(Fastlane::Actions::LatestAppcenterBuildNumberAction).to receive(:prompt_for_apps).and_return([app])
        stub_get_apps_success(200)
        stub_get_releases_success(200)
      end

      it 'prompts for an app name' do
        expect(build_number).to eq('1.0.4.105')
      end
    end

    context 'when no owner name is set' do
      let(:build_number) do
        build_number = Fastlane::FastFile.new.parse("lane :test do
          latest_appcenter_build_number(
            api_token: '1234',
            app_name: 'App-Name'
          )
        end").runner.execute(:test)
      end

      before do
        allow(Fastlane::Actions::LatestAppcenterBuildNumberAction).to receive(:prompt_for_apps).and_return([app])
        stub_get_apps_success(200)
        stub_get_releases_success(200)
      end

      it 'prompts for an app name' do
        expect(build_number).to eq('1.0.4.105')
      end
    end

    context 'when a valid owner, app name, and token build numbers are requested' do
      let(:build_number) do
        build_number = Fastlane::FastFile.new.parse("lane :test do
          latest_appcenter_build_number(
            api_token: '1234',
            owner_name: 'owner-name',
            app_name: 'App-Name'
          )
        end").runner.execute(:test)
      end

      before do
        stub_get_releases_success(200)
      end

      it 'returns the version number correctly' do
        expect(build_number).to eq('1.0.4.105')
      end
    end
  end
end

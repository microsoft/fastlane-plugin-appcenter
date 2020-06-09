require "json"
require "net/http"
require "fastlane_core/ui/ui"

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Actions
    class AppcenterFetchBuildNumberForTrainAction < Action
      def self.description
        "Fetches the latest build number of a version train for an app from App Center"
      end

      def self.authors
        ["Qutaibah"]
      end

      def self.run(params)
        api_token = params[:api_token]
        app_name = params[:app_name]
        owner_name = params[:owner_name]
        version_train = params[:version_train]

        releases = Helper::AppcenterHelper.fetch_releases(
          api_token: api_token,
          owner_name: owner_name,
          app_name: app_name,
        )

        UI.abort_with_message!("No versions found for '#{app_name}' owned by #{owner_name}") unless releases

        sorted_releases =
          releases.select { |x| x["short_version"] == version_train }.sort_by do |x|
            x["id"]
          end

        latest_release = sorted_releases.last

        if latest_release.nil?
          UI.error("Version '#{version_train}' has no builds yet")
          return nil
        end

        return {
                 "id" => latest_release["id"],
                 "version" => latest_release["short_version"],
                 "build_number" => latest_release["version"],
               }
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "APPCENTER_VERSION_TRAIN",
                                       description: "The version train to get the latest release for it",
                                       verify_block: proc do |value|
                                         UI.user_error!("No version train was provided, pass using `version_train: 'version'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "APPCENTER_API_TOKEN",
                                       description: "API Token for App Center Access",
                                       verify_block: proc do |value|
                                         UI.user_error!("No API token for App Center given, pass using `api_token: 'token'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :owner_name,
                                       env_name: "APPCENTER_OWNER_NAME",
                                       description: "Name of the owner of the application on App Center",
                                       verify_block: proc do |value|
                                         UI.user_error!("No owner name for App Center given, pass using `owner_name: 'owner name'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       env_name: "APPCENTER_APP_NAME",
                                       description: "Name of the application on App Center",
                                       verify_block: proc do |value|
                                         UI.user_error!("No app name for App Center given, pass using `app_name: 'app name'`") unless value && !value.empty?
                                       end),
        ]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end

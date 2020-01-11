require 'json'
require 'net/http'
require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Actions
    class AppcenterFetchVersionNumberAction < Action
      def self.description
        "Fetches the latest version number of an app from App Center"
      end

      def self.authors
        ["jspargo", "ShopKeep"]
      end

      def self.run(config)
        app_name = config[:app_name]
        owner_name = config[:owner_name]
        if app_name.nil? && owner_name.nil?
          owner_and_app_name = get_owner_and_app_name(config[:api_token])
          app_name = owner_and_app_name[0]
          owner_name = owner_and_app_name[1]
        end

        unless app_name.nil?
          unless Helper::AppcenterHelper.check_valid_name(app_name)
            UI.user_error!("The `app_name` ('#{app_name}') cannot contains spaces and must only contain alpha numeric characters and dashes")
            return nil
          end
        end

        if owner_name.nil?
          owner_name = get_owner_name(config[:api_token], app_name)
        else
          unless Helper::AppcenterHelper.check_valid_name(owner_name)
            UI.user_error!("The `owner_name` ('#{owner_name}') cannot contains spaces and must only contain lowercased alpha numeric characters and dashes")
            return nil
          end
        end

        if app_name.nil?
          app_name = get_owner_and_app_name(config[:api_token])[0]
        end

        if app_name.nil? || owner_name.nil?
          UI.user_error!("No app '#{app_name}' found for owner #{owner_name}")
          return nil
        end

        host_uri = URI.parse('https://api.appcenter.ms')
        http = Net::HTTP.new(host_uri.host, host_uri.port)
        http.use_ssl = true
        list_request = Net::HTTP::Get.new("/v0.1/apps/#{owner_name}/#{app_name}/releases")
        list_request['X-API-Token'] = config[:api_token]
        list_response = http.request(list_request)

        if list_response.kind_of?(Net::HTTPForbidden)
          UI.user_error!("API Key not valid for '#{owner_name}'. This will be because either the API Key or the `owner_name` are incorrect")
          return nil
        end

        if list_response.kind_of?(Net::HTTPNotFound)
          UI.user_error!("No app or owner found with `app_name`: '#{app_name}' and `owner_name`: '#{owner_name}'")
          return nil
        end

        releases = JSON.parse(list_response.body)
        if releases.nil?
          UI.user_error!("No versions found for '#{app_name}' owned by #{owner_name}")
          return nil
        end

        sorted_release = releases.sort_by { |release| release['id'] }.reverse!
        latest_build = sorted_release.first

        if latest_build.nil?
          UI.user_error!("The app has no versions yet")
          return nil
        end

        return latest_build['version']
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "APPCENTER_API_TOKEN",
                                       description: "API Token for AppCenter Access",
                                       verify_block: proc do |value|
                                         UI.user_error!("No API token for AppCenter given, pass using `api_token: 'token'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :owner_name,
                                       env_name: "APPCENTER_OWNER_NAME",
                                       optional: true,
                                       description: "Name of the owner of the application on AppCenter",
                                       verify_block: proc do |value|
                                         UI.user_error!("No owner name for AppCenter given, pass using `owner_name: 'owner name'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       env_name: "APPCENTER_APP_NAME",
                                       optional: true,
                                       description: "Name of the application on AppCenter",
                                       verify_block: proc do |value|
                                         UI.user_error!("No app name for AppCenter given, pass using `app_name: 'app name'`") unless value && !value.empty?
                                       end)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end

      def self.get_owner_and_app_name(api_token)
        apps = get_apps(api_token)
        app_matches = prompt_for_apps(apps)
        return unless app_matches.count > 0
        selected_app = app_matches.first
        name = selected_app['name'].to_s
        owner = selected_app['owner']['name'].to_s
        return name, owner
      end

      def self.get_owner_name(api_token, app_name)
        apps = get_apps(api_token)
        return unless apps.count > 0
        app_matches = apps.select { |app| app['name'] == app_name }
        return unless app_matches.count > 0
        selected_app = app_matches.first

        owner = selected_app['owner']['name'].to_s
        return owner
      end

      def self.get_apps(api_token)
        host_uri = URI.parse('https://api.appcenter.ms')
        http = Net::HTTP.new(host_uri.host, host_uri.port)
        http.use_ssl = true
        apps_request = Net::HTTP::Get.new("/v0.1/apps")
        apps_request['X-API-Token'] = api_token
        apps_response = http.request(apps_request)
        return [] unless apps_response.kind_of?(Net::HTTPOK)
        return JSON.parse(apps_response.body)
      end

      def self.prompt_for_apps(apps)
        app_names = apps.map { |app| app['name'] }.sort
        selected_app_name = UI.select("Select your project: ", app_names)
        return apps.select { |app| app['name'] == selected_app_name }
      end
    end
  end
end

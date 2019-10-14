require 'fastlane/action'
require 'csv'
require 'faraday'

module Fastlane
  module Actions
    module SharedValues
      APPCENTER_API_TOKEN = :APPCENTER_API_TOKEN
      APPCENTER_OWNER_NAME = :APPCENTER_OWNER_NAME
      APPCENTER_APP_NAME = :APPCENTER_APP_NAME
    end

    class AppcenterFetchDevicesAction < Action
      def self.run(params)
        api_token = params[:api_token]
        owner_name = params[:owner_name]
        app_name = params[:app_name]

        Actions.lane_context[SharedValues::APPCENTER_API_TOKEN] = api_token
        Actions.lane_context[SharedValues::APPCENTER_OWNER_NAME] = owner_name
        Actions.lane_context[SharedValues::APPCENTER_APP_NAME] = app_name

        distribution_groups = JSON.parse(
          self.fetch_distribution_groups(
            api_token: api_token,
            owner_name: owner_name,
            app_name: app_name
          )
        )

        devices = []
        distribution_groups.each do |group|
          group_name = group['name']

          devices << self.fetch_devices(
            api_token: api_token,
            owner_name: owner_name,
            app_name: app_name,
            distribution_group: group_name
          )
        end

        self.write_devices(devices: devices, devices_file: params[:devices_file])
      end

      def self.fetch_distribution_groups(api_token:, owner_name:, app_name:)
        conn = Faraday.new(url: 'https://api.appcenter.ms')

        response = conn.get do |req|
          req.url "/v0.1/apps/#{owner_name}/#{app_name}/distribution_groups/"
          req.headers['X-API-Token'] = api_token
        end

        return response.body
      end

      def self.fetch_devices(api_token:, owner_name:, app_name:, distribution_group:)
        conn = Faraday.new(url: 'https://api.appcenter.ms')

        response = conn.get do |req|
          req.url "/v0.1/apps/#{owner_name}/#{app_name}/distribution_groups/#{distribution_group}/devices/download_devices_list"
          req.headers['X-API-Token'] = api_token
        end

        return response.body
      end

      def self.write_devices(devices:, devices_file:)
        CSV.open(devices_file, 'w',
                 write_headers: true,
                 headers: ['Device ID', 'Device Name'],
                 col_sep: "\t") do |csv|

          devices.each do |device|
            CSV.parse(device, { col_sep: "\t", headers: true }) do |row|
              csv << row
            end
          end
        end
      end

      def self.description
        "Fetches a list of devices from App Center to distribute an iOS app to."
      end

      def self.authors
        ["benkane"]
      end

      def self.return_value
        "CSV file formatted for multi-device registration with Apple"
      end

      def self.details
        "List is a tab-delimited CSV file containing every device from every distribution group for an app in App Center. Especially useful when combined with register_devices and match to automatically register and provision devices with Apple."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                  env_name: "APPCENTER_API_TOKEN",
                                  sensitive: true,
                               description: "API Token for App Center",
                                  optional: false,
                                      type: String,
                             verify_block: proc do |value|
                               UI.user_error!("No API token for App Center given, pass using `api_token: 'token'`") unless value && !value.empty?
                             end),
          FastlaneCore::ConfigItem.new(key: :owner_name,
                                  env_name: "APPCENTER_OWNER_NAME",
                               description: "Owner name",
                                  optional: false,
                                      type: String,
                              verify_block: proc do |value|
                                UI.user_error!("No Owner name for App Center given, pass using `owner_name: 'name'`") unless value && !value.empty?
                              end),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                  env_name: "APPCENTER_APP_NAME",
                               description: "App name",
                                  optional: false,
                                      type: String,
                              verify_block: proc do |value|
                                UI.user_error!("No App name given, pass using `app_name: 'app name'`") unless value && !value.empty?
                              end),
          FastlaneCore::ConfigItem.new(key: :devices_file,
                                  env_name: "FL_REGISTER_DEVICES_FILE",
                               description: "File to save devices to",
                                      type: String,
                             default_value: "devices.txt",
                              verify_block: proc do |value|
                                UI.important("Important: Devices file is #{value}. If you plan to upload this file to Apple Developer Center, the file must have the .txt extension") unless value && value.end_with?('.txt')
                              end)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end

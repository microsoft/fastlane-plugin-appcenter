require 'fastlane/action'
require 'csv'
require 'faraday'

module Fastlane
  module Actions
    module SharedValues
      APPCENTER_API_TOKEN = :APPCENTER_API_TOKEN
      APPCENTER_OWNER_NAME = :APPCENTER_OWNER_NAME
      APPCENTER_APP_NAME = :APPCENTER_APP_NAME
      APPCENTER_DISTRIBUTE_DESTINATIONS = :APPCENTER_DISTRIBUTE_DESTINATIONS
    end

    class AppcenterFetchDevicesAction < Action
      def self.run(params)
        api_token = params[:api_token]
        owner_name = params[:owner_name]
        app_name = params[:app_name]
        destinations = params[:destinations]

        Actions.lane_context[SharedValues::APPCENTER_API_TOKEN] = api_token
        Actions.lane_context[SharedValues::APPCENTER_OWNER_NAME] = owner_name
        Actions.lane_context[SharedValues::APPCENTER_APP_NAME] = app_name

        group_names = []
        if destinations == '*'
          UI.message("Looking up all distribution groups for #{owner_name}/#{app_name}")
          distribution_groups = Helper::AppcenterHelper.fetch_distribution_groups(
            api_token: api_token,
            owner_name: owner_name,
            app_name: app_name
          )
          UI.abort_with_message!("Failed to list distribution groups for #{owner_name}/#{app_name}") unless distribution_groups
          distribution_groups.each do |group|
            group_names << group['name']
          end
        else
          group_names += destinations.split(',').map(&:strip)
        end

        Actions.lane_context[SharedValues::APPCENTER_DISTRIBUTE_DESTINATIONS] = group_names.join(',')

        devices = []
        group_names.each do |group_name|
          group_devices = Helper::AppcenterHelper.fetch_devices(
            api_token: api_token,
            owner_name: owner_name,
            app_name: app_name,
            distribution_group: group_name
          )
          UI.abort_with_message!("Failed to get devices for group '#{group_name}'") unless group_devices
          devices << group_devices
        end

        self.write_devices(devices: devices, devices_file: params[:devices_file])
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
        "Fetches a list of devices from App Center to distribute an iOS app to"
      end

      def self.authors
        ["benkane"]
      end

      def self.return_value
        "CSV file formatted for multi-device registration with Apple"
      end

      def self.details
        "List is a tab-delimited CSV file containing every device from specified distribution groups for an app in App Center. " +
          "Especially useful when combined with register_devices and match to automatically register and provision devices with Apple. " +
          "By default, only the Collaborators group will be included, use `destination: '*'` to match all groups."
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
                              end),
          FastlaneCore::ConfigItem.new(key: :destinations,
                                  env_name: "APPCENTER_DISTRIBUTE_DESTINATIONS",
                               description: "Comma separated list of distribution group names. Default is 'Collaborators', use '*' for all distribution groups",
                             default_value: "Collaborators",
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end

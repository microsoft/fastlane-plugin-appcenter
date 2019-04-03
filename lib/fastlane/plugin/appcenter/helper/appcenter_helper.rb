module Fastlane
  module Helper
    module SharedValues
      APPCENTER_DOWNLOAD_LINK = :APPCENTER_DOWNLOAD_LINK
      APPCENTER_BUILD_INFORMATION = :APPCENTER_BUILD_INFORMATION
    end

    class AppcenterHelper

      # create request
      def self.connection(upload_url = false, dsym = false)
        require 'faraday'
        require 'faraday_middleware'

        options = {
          url: upload_url ? upload_url : "https://api.appcenter.ms"
        }

        Faraday.new(options) do |builder|
          if upload_url
            builder.request :multipart unless dsym
            builder.request :url_encoded unless dsym
          else
            builder.request :json
          end
          builder.response :json, content_type: /\bjson$/
          builder.use FaradayMiddleware::FollowRedirects
          builder.adapter :net_http
        end
      end

      # creates new release upload
      # returns:
      # upload_id
      # upload_url
      def self.create_release_upload(api_token, owner_name, app_name)
        connection = self.connection

        response = connection.post do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/release_uploads")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = {}
        end

        case response.status
        when 200...300
          UI.message("DEBUG: #{JSON.pretty_generate(response.body)}\n") if ENV['DEBUG']
          response.body
        when 401
          UI.user_error!("Auth Error, provided invalid token")
          false
        when 404
          UI.error("Not found, invalid owner or application name")
          false
        else
          UI.error("Error #{response.status}: #{response.body}")
          false
        end
      end

      # creates new dSYM upload in appcenter
      # returns:
      # symbol_upload_id
      # upload_url
      # expiration_date
      def self.create_dsym_upload(api_token, owner_name, app_name)
        connection = self.connection

        response = connection.post do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/symbol_uploads")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = {
            symbol_type: 'Apple'
          }
        end

        case response.status
        when 200...300
          UI.message("DEBUG: #{JSON.pretty_generate(response.body)}\n") if ENV['DEBUG']
          response.body
        when 401
          UI.user_error!("Auth Error, provided invalid token")
          false
        when 404
          UI.error("Not found, invalid owner or application name")
          false
        else
          UI.error("Error #{response.status}: #{response.body}")
          false
        end
      end

      # committs or aborts dsym upload
      def self.update_dsym_upload(api_token, owner_name, app_name, symbol_upload_id, status)
        connection = self.connection

        response = connection.patch do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/symbol_uploads/#{symbol_upload_id}")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = {
            "status" => status
          }
        end

        case response.status
        when 200...300
          UI.message("DEBUG: #{JSON.pretty_generate(response.body)}\n") if ENV['DEBUG']
          response.body
        else
          UI.error("Error #{response.status}: #{response.body}")
          false
        end
      end

      # upload dSYM files to specified upload url
      # if succeed, then commits the upload
      # otherwise aborts
      def self.upload_dsym(api_token, owner_name, app_name, dsym, symbol_upload_id, upload_url)
        connection = self.connection(upload_url, true)

        response = connection.put do |req|
          req.headers['x-ms-blob-type'] = "BlockBlob"
          req.headers['Content-Length'] = File.size(dsym).to_s
          req.headers['internal-request-source'] = "fastlane"
          req.body = Faraday::UploadIO.new(dsym, 'application/octet-stream') if dsym && File.exist?(dsym)
        end

        case response.status
        when 200...300
          self.update_dsym_upload(api_token, owner_name, app_name, symbol_upload_id, 'committed')
          UI.success("dSYM uploaded")
        else
          UI.error("Error uploading dSYM #{response.status}: #{response.body}")
          self.update_dsym_upload(api_token, owner_name, app_name, symbol_upload_id, 'aborted')
          UI.error("dSYM upload aborted")
          false
        end
      end

      # upload binary for specified upload_url
      # if succeed, then commits the release
      # otherwise aborts
      def self.upload_build(api_token, owner_name, app_name, file, upload_id, upload_url)
        connection = self.connection(upload_url)

        options = {}
        options[:upload_id] = upload_id
        # ipa field is used both for .apk and .ipa files
        options[:ipa] = Faraday::UploadIO.new(file, 'application/octet-stream') if file && File.exist?(file)

        response = connection.post do |req|
          req.headers['internal-request-source'] = "fastlane"
          req.body = options
        end

        case response.status
        when 200...300
          UI.message("Binary uploaded")
          self.update_release_upload(api_token, owner_name, app_name, upload_id, 'committed')
        else
          UI.error("Error uploading binary #{response.status}: #{response.body}")
          self.update_release_upload(api_token, owner_name, app_name, upload_id, 'aborted')
          UI.error("Release aborted")
          false
        end
      end

      # Commits or aborts the upload process for a release
      def self.update_release_upload(api_token, owner_name, app_name, upload_id, status)
        connection = self.connection

        response = connection.patch do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/release_uploads/#{upload_id}")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = {
            "status" => status
          }
        end

        case response.status
        when 200...300
          UI.message("DEBUG: #{JSON.pretty_generate(response.body)}\n") if ENV['DEBUG']
          response.body
        else
          UI.error("Error #{response.status}: #{response.body}")
          false
        end
      end

      # get existing release
      def self.get_release(api_token, owner_name, app_name, release_id)
        connection = self.connection
        response = connection.get do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/releases/#{release_id}")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
        end

        case response.status
        when 200...300
          release = response.body
          UI.message("DEBUG: #{JSON.pretty_generate(release)}") if ENV['DEBUG']
          release
        when 404
          UI.error("Not found, invalid release url")
          false
        else
          UI.error("Error fetching information about release #{response.status}: #{response.body}")
          false
        end
      end

      # get distribution group
      def self.get_group(api_token, owner_name, app_name, group_name)
        connection = self.connection

        response = connection.get do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/distribution_groups/#{group_name}")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
        end

        case response.status
        when 200...300
          group = response.body
          UI.message("DEBUG: received group #{JSON.pretty_generate(group)}") if ENV['DEBUG']
          group
        when 404
          UI.error("Not found, invalid distribution group name")
          false
        else
          UI.error("Error getting group #{response.status}: #{response.body}")
          false
        end
      end

      # add release to destination
      def self.update_release(api_token, owner_name, app_name, release_id, release_notes = '')
        connection = self.connection

        response = connection.put do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/releases/#{release_id}")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = {
            "release_notes" => release_notes
          }
        end

        case response.status
        when 200...300
          # get full release info
          release = self.get_release(api_token, owner_name, app_name, release_id)
          return false unless release
          download_url = release['download_url']

          UI.message("DEBUG: #{JSON.pretty_generate(release)}") if ENV['DEBUG']

          Actions.lane_context[SharedValues::APPCENTER_DOWNLOAD_LINK] = download_url
          Actions.lane_context[SharedValues::APPCENTER_BUILD_INFORMATION] = release

          UI.success("Release #{release['short_version']} was successfully upddated")

          release
        when 404
          UI.error("Not found, invalid release id")
          false
        else
          UI.error("Error adding updating release #{response.status}: #{response.body}")
          false
        end
      end

      # add release to distribution group
      def self.add_to_group(api_token, owner_name, app_name, release_id, group_id)
        connection = self.connection

        UI.message("DEBUG: getting #{release_id}") if ENV['DEBUG']

        response = connection.post do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/releases/#{release_id}/groups")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = {
            "id" => group_id
          }
        end

        case response.status
        when 200...300
          # get full release info
          release = self.get_release(api_token, owner_name, app_name, release_id)
          return false unless release
          download_url = release['download_url']

          UI.message("DEBUG: received release #{JSON.pretty_generate(release)}") if ENV['DEBUG']

          Actions.lane_context[SharedValues::APPCENTER_DOWNLOAD_LINK] = download_url
          Actions.lane_context[SharedValues::APPCENTER_BUILD_INFORMATION] = release

          UI.message("Public Download URL: #{download_url}") if download_url

          release
        when 404
          UI.error("Not found, invalid distribution group name")
          false
        else
          UI.error("Error adding to group #{response.status}: #{response.body}")
          false
        end
      end

      # add release to destination
      def self.add_to_destination(api_token, owner_name, app_name, release_id, destination_name, release_notes = '')
        connection = self.connection

        response = connection.patch do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/releases/#{release_id}")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = {
            "destination_name" => destination_name,
            "release_notes" => release_notes
          }
        end

        case response.status
        when 200...300
          # get full release info
          release = self.get_release(api_token, owner_name, app_name, release_id)
          return false unless release
          download_url = release['download_url']

          UI.message("DEBUG: #{JSON.pretty_generate(release)}") if ENV['DEBUG']

          Actions.lane_context[SharedValues::APPCENTER_DOWNLOAD_LINK] = download_url
          Actions.lane_context[SharedValues::APPCENTER_BUILD_INFORMATION] = release

          UI.message("Public Download URL: #{download_url}") if download_url
          UI.success("Release #{release['short_version']} was successfully distributed to destination \"#{destination_name}\"")

          release
        when 404
          UI.error("Not found, invalid destination name")
          false
        else
          UI.error("Error adding to destination #{response.status}: #{response.body}")
          false
        end
      end

      # returns true if app exists, false in case of 404 and error otherwise
      def self.get_app(api_token, owner_name, app_name)
        connection = self.connection

        response = connection.get do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
        end

        case response.status
        when 200...300
          UI.message("DEBUG: #{JSON.pretty_generate(response.body)}\n") if ENV['DEBUG']
          true
        when 404
          UI.message("DEBUG: #{JSON.pretty_generate(response.body)}\n") if ENV['DEBUG']
          false
        else
          UI.error("Error #{response.status}: #{response.body}")
          false
        end
      end

      # returns true if app exists, false in case of 404 and error otherwise
      def self.create_app(api_token, owner_name, app_name, os, platform)
        connection = self.connection

        response = connection.post do |req|
          req.url("/v0.1/apps")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = {
            "display_name" => app_name,
            "name" => app_name,
            "os" => os,
            "platform" => platform
          }
        end

        case response.status
        when 200...300
          created = response.body
          UI.message("DEBUG: #{JSON.pretty_generate(created)}") if ENV['DEBUG']
          UI.success("Created #{os}/#{platform} app with name \"#{created['name']}\"")
          true
        else
          UI.error("Error creating app #{response.status}: #{response.body}")
          false
        end
      end
    end
  end
end

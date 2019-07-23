module Fastlane
  module Helper
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
        when 500...600
          UI.crash!("Internal Service Error, please try again later")
        else
          UI.error("Error #{response.status}: #{response.body}")
          false
        end
      end

      # creates new mapping upload in appcenter
      # returns:
      # symbol_upload_id
      # upload_url
      # expiration_date
      def self.create_mapping_upload(api_token, owner_name, app_name, file_name, build_number, version)
        connection = self.connection

        response = connection.post do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/symbol_uploads")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = {
            symbol_type: "AndroidProguard",
            file_name: file_name,
            build: build_number,
            version: version,
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

      # commits or aborts symbol upload
      def self.update_symbol_upload(api_token, owner_name, app_name, symbol_upload_id, status)
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

      # upload symbol (dSYM or mapping) files to specified upload url
      # if succeed, then commits the upload
      # otherwise aborts
      def self.upload_symbol(api_token, owner_name, app_name, symbol, symbol_type, symbol_upload_id, upload_url)
        connection = self.connection(upload_url, true)

        response = connection.put do |req|
          req.headers['x-ms-blob-type'] = "BlockBlob"
          req.headers['Content-Length'] = File.size(symbol).to_s
          req.headers['internal-request-source'] = "fastlane"
          req.body = Faraday::UploadIO.new(symbol, 'application/octet-stream') if symbol && File.exist?(symbol)
        end

        logType = "dSYM" if (symbol_type == "Apple")
        logType = "mapping" if (symbol_type == "Android")

        case response.status
        when 200...300
          self.update_symbol_upload(api_token, owner_name, app_name, symbol_upload_id, 'committed')
          UI.success("#{logType} uploaded")
        else
          UI.error("Error uploading #{logType} #{response.status}: #{response.body}")
          self.update_symbol_upload(api_token, owner_name, app_name, symbol_upload_id, 'aborted')
          UI.error("#{logType} upload aborted")
          false
        end
      end

      # upload binary for specified upload_url
      # if succeed, then commits the release
      # otherwise aborts
      def self.upload_build(api_token, owner_name, app_name, file, upload_id, upload_url, timeout)
        connection = self.connection(upload_url)

        options = {}
        options[:upload_id] = upload_id
        # ipa field is used for .apk, .aab and .ipa files
        options[:ipa] = Faraday::UploadIO.new(file, 'application/octet-stream') if file && File.exist?(file)

        response = connection.post do |req|
          req.options.timeout = timeout
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
        when 500...600
          UI.crash!("Internal Service Error, please try again later")
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

      # get distribution group or store
      def self.get_destination(api_token, owner_name, app_name, destination_type, destination_name)
        connection = self.connection

        response = connection.get do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/distribution_#{destination_type}s/#{ERB::Util.url_encode(destination_name)}")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
        end

        case response.status
        when 200...300
          destination = response.body
          UI.message("DEBUG: received #{destination_type} #{JSON.pretty_generate(destination)}") if ENV['DEBUG']
          destination
        when 404
          UI.error("Not found, invalid distribution #{destination_type} name")
          false
        else
          UI.error("Error getting #{destination_type} #{response.status}: #{response.body}")
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

          Actions.lane_context[Fastlane::Actions::SharedValues::APPCENTER_DOWNLOAD_LINK] = download_url
          Actions.lane_context[Fastlane::Actions::SharedValues::APPCENTER_BUILD_INFORMATION] = release

          UI.message("Release #{release['short_version']} was successfully updated")

          release
        when 404
          UI.error("Not found, invalid release id")
          false
        else
          UI.error("Error adding updating release #{response.status}: #{response.body}")
          false
        end
      end

      # add release to distribution group or store
      def self.add_to_destination(api_token, owner_name, app_name, release_id, destination_type, destination_id, mandatory_update = false, notify_testers = false)
        connection = self.connection

        UI.message("DEBUG: getting #{release_id}") if ENV['DEBUG']

        body = { "id" => destination_id }
        if destination_type == "group"
          body["mandatory_update"] = mandatory_update
          body["notify_testers"] = notify_testers
        end

        response = connection.post do |req|
          req.url("/v0.1/apps/#{owner_name}/#{app_name}/releases/#{release_id}/#{destination_type}s")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = body
        end

        case response.status
        when 200...300
          # get full release info
          release = self.get_release(api_token, owner_name, app_name, release_id)
          return false unless release
          download_url = release['download_url']

          UI.message("DEBUG: received release #{JSON.pretty_generate(release)}") if ENV['DEBUG']

          Actions.lane_context[Fastlane::Actions::SharedValues::APPCENTER_DOWNLOAD_LINK] = download_url
          Actions.lane_context[Fastlane::Actions::SharedValues::APPCENTER_BUILD_INFORMATION] = release

          UI.message("Public Download URL: #{download_url}") if download_url

          release
        when 404
          UI.error("Not found, invalid distribution #{destination_type} name")
          false
        else
          UI.error("Error adding to #{destination_type} #{response.status}: #{response.body}")
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
          UI.error("Error getting app #{owner_name}/#{app_name}, #{response.status}: #{response.body}")
          false
        end
      end

      # returns true if app exists, false in case of 404 and error otherwise
      def self.create_app(api_token, owner_name, app_name, app_display_name, os, platform)
        connection = self.connection

        response = connection.post do |req|
          req.url("/v0.1/apps")
          req.headers['X-API-Token'] = api_token
          req.headers['internal-request-source'] = "fastlane"
          req.body = {
            "display_name" => app_display_name,
            "name" => app_name,
            "os" => os,
            "platform" => platform
          }
        end

        case response.status
        when 200...300
          created = response.body
          UI.message("DEBUG: #{JSON.pretty_generate(created)}") if ENV['DEBUG']
          UI.success("Created #{os}/#{platform} app with name \"#{created['name']}\" and display name \"#{created['display_name']}\"")
          true
        else
          UI.error("Error creating app #{response.status}: #{response.body}")
          false
        end
      end
    end
  end
end

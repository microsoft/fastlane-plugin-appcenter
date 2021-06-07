def stub_check_app(status, app_name = "app", owner_name = "owner")
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}")
    .to_return(
      status: status,
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_check_app_exception(status, app_name = "app", owner_name = "owner")
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}")
    .to_raise(Faraday::Error).then
    .to_return(
      status: status,
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_check_app_429(status, app_name = "app", owner_name = "owner")
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}")
    .to_return(
      status: 429,
      headers: { 'Content-Type' => 'application/json' }
    ).then
    .to_return(
      status: status,
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_app(status, app_name = "app", app_display_name = "app", app_os = "Android", app_platform = "Java", owner_type = "user", owner_name = "owner")
  stub_request(:post, owner_type == "user" ? "https://api.appcenter.ms/v0.1/apps" : "https://api.appcenter.ms/v0.1/orgs/#{owner_name}/apps")
    .with(
      body: "{\"display_name\":\"#{app_display_name}\",\"name\":\"#{app_name}\",\"os\":\"#{app_os}\",\"platform\":\"#{app_platform}\"}"
    )
    .to_return(
      status: status,
      body: "{\"name\":\"app\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_app_exception(status, app_name = "app", app_display_name = "app", app_os = "Android", app_platform = "Java", owner_type = "user", owner_name = "owner")
  stub_request(:post, owner_type == "user" ? "https://api.appcenter.ms/v0.1/apps" : "https://api.appcenter.ms/v0.1/orgs/#{owner_name}/apps")
    .with(
      body: "{\"display_name\":\"#{app_display_name}\",\"name\":\"#{app_name}\",\"os\":\"#{app_os}\",\"platform\":\"#{app_platform}\"}"
    )
    .to_raise(Faraday::Error).then
    .to_return(
      status: status,
      body: "{\"name\":\"app\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_app_429(status, app_name = "app", app_display_name = "app", app_os = "Android", app_platform = "Java", owner_type = "user", owner_name = "owner")
  stub_request(:post, owner_type == "user" ? "https://api.appcenter.ms/v0.1/apps" : "https://api.appcenter.ms/v0.1/orgs/#{owner_name}/apps")
    .with(
      body: "{\"display_name\":\"#{app_display_name}\",\"name\":\"#{app_name}\",\"os\":\"#{app_os}\",\"platform\":\"#{app_platform}\"}"
    )
    .to_return(
      status: 429,
      body: "{\"name\":\"app\"}",
      headers: { 'Content-Type' => 'application/json' }
    ).then
    .to_return(
      status: status,
      body: "{\"name\":\"app\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_release_upload(status, body = nil, app_name = "app", owner_name = "owner")
  stub_request(:post, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/uploads/releases")
    .with(body: body && JSON.generate(body) || "{}")
    .to_return(
      status: status,
      body: "{\"id\":\"upload_id\",\"upload_domain\":\"https://upload-domain.com\",\"package_asset_id\":\"1234\",\"url_encoded_token\":\"123abc\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_release_upload_exception(status, body = nil, app_name = "app", owner_name = "owner")
  stub_request(:post, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/uploads/releases")
    .with(body: body && JSON.generate(body) || "{}")
    .to_raise(Faraday::Error).then
    .to_return(
      status: status,
      body: "{\"id\":\"upload_id\",\"upload_domain\":\"https://upload-domain.com\",\"package_asset_id\":\"1234\",\"url_encoded_token\":\"123abc\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_release_upload_429(status, body = nil, app_name = "app", owner_name = "owner")
  stub_request(:post, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/uploads/releases")
    .with(body: body && JSON.generate(body) || "{}")
    .to_return(
      status: 429,
      body: "{\"id\":\"upload_id\",\"upload_domain\":\"https://upload-domain.com\",\"package_asset_id\":\"1234\",\"url_encoded_token\":\"123abc\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
    .to_return(
      status: status,
      body: "{\"id\":\"upload_id\",\"upload_domain\":\"https://upload-domain.com\",\"package_asset_id\":\"1234\",\"url_encoded_token\":\"123abc\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_dsym_upload(status)
  stub_request(:post, "https://api.appcenter.ms/v0.1/apps/owner/app/symbol_uploads")
    .with(body: "{\"symbol_type\":\"Apple\"}")
    .to_return(
      status: status,
      body: "{\"symbol_upload_id\":\"symbol_upload_id\",\"upload_url\":\"https://upload_dsym.com\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_mapping_upload(status, version, build, file_name = "mapping.txt")
  stub_request(:post, "https://api.appcenter.ms/v0.1/apps/owner/app/symbol_uploads")
    .with(body: "{\"symbol_type\":\"AndroidProguard\",\"file_name\":\"#{file_name}\",\"build\":\"#{build}\",\"version\":\"#{version}\"}")
    .to_return(
      status: status,
      body: "",
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_set_release_upload_metadata(status, file_name = "apk_file_empty.apk", body = "{\"error\": false, \"chunk_size\": 0}")
  content_type = Fastlane::Actions::Constants::CONTENT_TYPES[File.extname(file_name).delete('.').to_sym] || "application/octet-stream"
  stub_request(:post, "https://upload-domain.com/upload/set_metadata/1234?content_type=#{content_type}&file_name=#{file_name}&file_size=0&token=123abc")
    .to_return(status: status, body: body, headers: { 'Content-Type' => 'application/json' })
end

def stub_finish_release_upload(status, body = "{\"error\": false}")
  stub_request(:post, "https://upload-domain.com/upload/finished/1234?token=123abc")
    .to_return(status: status, body: body, headers: { 'Content-Type' => 'application/json' })
end

def stub_poll_sleeper
  allow_any_instance_of(Object).to receive(:sleep)
end

def stub_poll_for_release_id(status, app_name = "app", owner_name = "owner", body = "{\"release_distinct_id\":1,\"upload_status\":\"readyToBePublished\"}")
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/uploads/releases/upload_id")
    .to_return(status: status, body: "{\"upload_status\":\"uploadFinished\"}", headers: { 'Content-Type' => 'application/json' }).times(2).then
    .to_return(status: status, body: body, headers: { 'Content-Type' => 'application/json' })
end

def stub_upload_build(status)
  allow_any_instance_of(File).to receive(:each_chunk).and_yield("test")
  stub_request(:post, "https://upload-domain.com/upload/upload_chunk/1234?token=123abc&block_number=1")
    .to_return(status: status, body: "{\"error\": false}", headers: { 'Content-Type' => 'application/json' })
end

def stub_upload_dsym(status)
  stub_request(:put, "https://upload_dsym.com/")
    .to_return(status: status, body: "", headers: {})
end

def stub_upload_mapping(status)
  stub_request(:put, "https://upload_dsym.com/")
    .to_return(status: status, body: "", headers: {})
end

def stub_update_release_upload(status, release_status, app_name = "app", owner_name = "owner")
  stub_request(:patch, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/uploads/releases/upload_id")
    .with(
      body: "{\"upload_status\":\"#{release_status}\",\"id\":\"upload_id\"}"
    )
    .to_return(status: status, body: "{\"release_id\":\"1\"}", headers: { 'Content-Type' => 'application/json' })
end

def stub_update_dsym_upload(status, release_status)
  stub_request(:patch, "https://api.appcenter.ms/v0.1/apps/owner/app/symbol_uploads/symbol_upload_id")
    .with(
      body: "{\"status\":\"#{release_status}\"}"
    )
    .to_return(status: status, body: "{\"release_id\":\"1\"}", headers: { 'Content-Type' => 'application/json' })
end

def stub_update_mapping_upload(status, release_status)
  stub_request(:patch, "https://api.appcenter.ms/v0.1/apps/owner/app/symbol_uploads/symbol_upload_id")
    .with(
      body: "{\"status\":\"#{release_status}\"}"
    )
    .to_return(status: status, body: "{\"release_id\":\"1\"}", headers: { 'Content-Type' => 'application/json' })
end

def stub_get_destination(status, app_name = "app", owner_name = "owner", destination_type = "group", destination_name = "Testers")
  stub_req = stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/distribution_#{destination_type}s/#{destination_name}")
  stub_req.to_return(status: status, body: "{\"id\":\"1\"}", headers: { 'Content-Type' => 'application/json' })
  stub_req
end

def stub_update_release(status, release_notes = 'autogenerated changelog', app_name = "app", owner_name = "owner")
  stub_request(:put, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/releases/1")
    .with(
      body: "{\"release_notes\":\"#{release_notes}\"}"
    )
    .to_return(status: status, body: "{\"version\":\"3\",\"short_version\":\"1.0.0\",\"download_link\":\"https://download.link\"}", headers: { 'Content-Type' => 'application/json' })
end

def stub_update_release_metadata(status, dsa_signature = 'test_signature', ed_signature = 'test_eddsa_signature', app_name = "app", owner_name = "owner")
  stub_request(:patch, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/releases/1")
    .with(
      body: "{\"metadata\":{\"dsa_signature\":\"#{dsa_signature}\",\"ed_signature\":\"#{ed_signature}\"}}"
    )
    .to_return(status: status, body: "{}", headers: { 'Content-Type' => 'application/json' })
end

def stub_get_release(status, app_name = "app", owner_name = "owner")
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/releases/1")
    .to_return(status: status, body: "{\"version\":\"3\",\"short_version\":\"1.0.0\",\"download_link\":\"https://download.link\"}", headers: { 'Content-Type' => 'application/json' })
end

def stub_add_to_destination(status, app_name = "app", owner_name = "owner", destination_type = "group", mandatory_update: false, notify_testers: false)
  if destination_type == "group"
    body = "{\"id\":\"1\",\"mandatory_update\":#{mandatory_update},\"notify_testers\":#{notify_testers}}"
  else
    body = "{\"id\":\"1\"}"
  end

  stub_request(:post, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/releases/1/#{destination_type}s")
    .with(
      body: body
    )
    .to_return(status: status, body: "{\"version\":\"3\",\"short_version\":\"1.0.0\",\"download_link\":\"https://download.link\"}", headers: { 'Content-Type' => 'application/json' })
end

def stub_add_new_app_to_distribution(status: 204, owner_name: 'owner', app_name: 'app', destination_name: 'Testers')
  stub_request(:post, "https://api.appcenter.ms/v0.1/orgs/#{owner_name}/distribution_groups/#{destination_name}/apps")
    .to_return(
      status: status
    )
end

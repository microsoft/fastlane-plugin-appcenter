def stub_check_app(status, app_name = "app", owner_name = "owner")
  success_json = JSON.parse(format(
                              File.read("spec/fixtures/apps/valid_app_response.json"),
                              app_name: app_name, owner_name: owner_name
                            ))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}")
    .to_return(
      status: status,
      body: success_json.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
end

def stub_create_app(status, app_name = "app", app_display_name = "app", app_os = "Android", app_platform = "Java", owner_type = "user", owner_name = "owner", app_secret = "app_secret")
  stub_request(:post, owner_type == "user" ? "https://api.appcenter.ms/v0.1/apps" : "https://api.appcenter.ms/v0.1/orgs/#{owner_name}/apps")
    .with(
      body: "{\"display_name\":\"#{app_display_name}\",\"name\":\"#{app_name}\",\"os\":\"#{app_os}\",\"platform\":\"#{app_platform}\"}"
    )
    .to_return(
      status: status,
      body: "{\"display_name\":\"#{app_display_name}\",\"name\":\"#{app_name}\",\"os\":\"#{app_os}\",\"platform\":\"#{app_platform}\",\"app_secret\":\"#{app_secret}\"}",
      headers: { 'Content-Type' => 'application/json' }
    )
end

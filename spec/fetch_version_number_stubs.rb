def stub_get_releases_success(status)
  success_json = JSON.parse(File.read("spec/fixtures/releases/valid_release_response.json"))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/owner-name/App-Name/releases")
    .to_return(status: status, body: success_json.to_json, headers: { 'Content-Type' => 'application/json' })
end

def stub_get_releases_exception
  success_json = JSON.parse(File.read("spec/fixtures/releases/valid_release_response.json"))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/owner-name/App-Name/releases")
    .to_raise(Faraday::Error).then
    .to_return(status: 200, body: success_json.to_json, headers: { 'Content-Type' => 'application/json' })
end

def stub_get_releases_429
  success_json = JSON.parse(File.read("spec/fixtures/releases/valid_release_response.json"))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/owner-name/App-Name/releases")
    .to_return(status: 429, headers: { 'Content-Type' => 'application/json' }).then
    .to_return(status: 200, body: success_json.to_json, headers: { 'Content-Type' => 'application/json' })
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

def stub_get_apps_exception
  success_json = JSON.parse(File.read("spec/fixtures/apps/valid_apps_response.json"))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps")
    .to_raise(Faraday::Error)
end

def stub_get_apps_429
  success_json = JSON.parse(File.read("spec/fixtures/apps/valid_apps_response.json"))
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps")
    .to_return(status: 429, headers: { 'Content-Type' => 'application/json' })
end

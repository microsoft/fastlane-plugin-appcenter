def stub_fetch_distribution_groups(owner_name:, app_name:, groups: ["Collaborators", "test-group-1", "test group 2"])
  body = groups.map { |g| { name: g } }
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/distribution_groups")
    .to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: body.to_json
    )
end

def stub_fetch_distribution_groups_chain(owner_name:, app_name:, response_codes:, groups: ["Collaborators", "test-group-1", "test group 2"])
  body = groups.map { |g| { name: g } }
  request = stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/distribution_groups")

  size = response_codes.length
  number = 0
  response_codes.each do |code|
    if code == -1
      request.to_raise(Faraday::Error)
    else
      request.to_return(
        status: code,
        headers: { 'Content-Type' => 'application/json' },
        body: body.to_json
      )
    end

    if number != size - 1
      request.then
    end

    number += 1
  end
end

def stub_fetch_devices(owner_name:, app_name:, distribution_group:)
  stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/distribution_groups/#{ERB::Util.url_encode(distribution_group)}/devices/download_devices_list")
    .to_return(
      status: 200,
      headers: { 'Content-Type' => 'text/csv; charset=utf-8' },
      body: "Device ID\tDevice Name\n
      1234567890abcdefghij1234567890abcdefghij\tDevice 1 - iPhone X\n
      abcdefghij1234567890abcdefghij1234567890\tDevice 2 - iPhone XS\n"
    )
end

def stub_fetch_devices_chain(owner_name:, app_name:, distribution_group:, response_codes:)
  request = stub_request(:get, "https://api.appcenter.ms/v0.1/apps/#{owner_name}/#{app_name}/distribution_groups/#{ERB::Util.url_encode(distribution_group)}/devices/download_devices_list")

  size = response_codes.length
  number = 0
  response_codes.each do |code|
    if code == -1
      request.to_raise(Faraday::Error)
    else
      request.to_return(
        status: code,
        headers: { 'Content-Type' => 'text/csv; charset=utf-8' },
        body: "Device ID\tDevice Name\n
        1234567890abcdefghij1234567890abcdefghij\tDevice 1 - iPhone X\n
        abcdefghij1234567890abcdefghij1234567890\tDevice 2 - iPhone XS\n"
      )
    end

    if number != size - 1
      request.then
    end

    number += 1
  end
end

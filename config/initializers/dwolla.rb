$dwolla = DwollaV2::Client.new(id: ENV["DWOLLA_CLIENT_ID"], secret: ENV["DWOLLA_CLIENT_SECRET"]) do |config|
  config.environment = :sandbox
  config.on_grant do |t|
    TokenData.create!(t.stringify_keys)
  end
end

begin
  TokenData.fresh_token_by!(account_id: ENV["DWOLLA_ACCOUNT_ID"])
rescue ActiveRecord::RecordNotFound => e
  puts "Creating a new token"
  TokenData.create!(account_id: ENV["DWOLLA_ACCOUNT_ID"], refresh_token: ENV["DWOLLA_ACCOUNT_REFRESH_TOKEN"], expires_in: -1)
end

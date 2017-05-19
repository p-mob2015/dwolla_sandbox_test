class TokenData
  # extend AttrEncrypted
  include Mongoid::Document
  include Mongoid::Timestamps

  DESIRED_FRESHNESS = 1.minute
  SECRET_KEY = ENV["SECRET_KEY"]

  # attr_encrypted :access_token, key: SECRET_KEY
  # attr_encrypted :refresh_token, key: SECRET_KEY

  field :access_token, type: String
  field :refresh_token, type: String
  field :scope, type: String
  field :account_id, type: String
  field :expires_in, type: Integer

  # look in the token_data table for the most recent token matching the given criteria
  # if one does not exist throw an `ActiveRecord::RecordNotFound` error
  # if one does exist convert the `TokenData` to a fresh `DwollaV2::Token` (see `#to_fresh_token`)
  def self.fresh_token_by!(criteria)
    latest_token = where(criteria).order(created_at: :desc).first
    if latest_token
      latest_token.to_fresh_token
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def to_fresh_token
    if expired?
      # if the token data is expired either refresh the token (account token) or get a new token (app token)
      puts "Token expired"
      account_id? \
        ? $dwolla.auths.refresh(self) \
        : $dwolla.auths.client
    else
      # if the token is not expired just convert it to a DwollaV2::Token
      $dwolla.tokens.new(self)
    end
  end

  private

  def expired?
    created_at < Time.now.utc - expires_in.seconds + DESIRED_FRESHNESS
  end
end
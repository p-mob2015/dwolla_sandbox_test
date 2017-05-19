module TokenConcern
  extend ActiveSupport::Concern

  private

  def account_token
    @account_token ||= TokenData.fresh_token_by! account_id: ENV["DWOLLA_ACCOUNT_ID"]
  end
end
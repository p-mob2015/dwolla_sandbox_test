class Dwolla
  include TokenConcern

  # We create a customer account(i.e. A homeowner's account). And one Dwolla account can have many customer accounts.
  def create_customer(firstName: "John", lastName: "Doe", email: "jd@doe.com")
    with_dwolla_exceptions_handler do
      account_token.post "customers", { firstName: firstName, lastName: lastName, email: email }
    end
  end

  # For the customer account, we link a bank account to it using `Account/Routing` mechanism. Terminology has it as `funding resource`
  def register_funding_source(routingNumber: "056008849", accountNumber: "12345678901234", type: "checking", name: "John Doe - bank account", customer_id: "97246728-dec0-48a0-8ec9-b6dbd32e4431")
    customer_url = "https://api-sandbox.dwolla.com/customers/#{customer_id}"
    with_dwolla_exceptions_handler do
      funding_source = account_token.post "#{customer_url}/funding-sources", {routingNumber: routingNumber, accountNumber: accountNumber, type: type, name: name}
    end
  end

  #(the source funding resource is obviously the Zilly Dwolla account's primary bank)
  def get_acount_funding_resources
    with_dwolla_exceptions_handler do
      account_token.get "https://api-sandbox.dwolla.com/accounts/#{ENV['DWOLLA_ACCOUNT_ID']}/funding-sources"
    end
  end

  # We initiate bank transfer from a `funding resource` to another `funding resource`
  def initiate_transfer(senderResourceId: "d8d53e82-53de-436b-b8fd-71192c87f5c8", receiverResourceId: "138ac65f-34ac-4592-ad5b-68cd7cd18518", amount: 100)
    request_body = {
      :_links => {
        :source => {
          :href => funding_resource_url(senderResourceId)
        },
        :destination => {
          :href => funding_resource_url(receiverResourceId)
        }
      },
      :amount => {
        :currency => "USD",
        :value => amount
      }
    }
    with_dwolla_exceptions_handler do
      account_token.post "transfers", request_body
    end
  end

  private

  def with_dwolla_exceptions_handler
    begin
      yield
    rescue => e
      puts e.to_json
    end
  end

  def funding_resource_url(resource_id)
    "https://api-sandbox.dwolla.com/funding-sources/#{resource_id}"
  end
end
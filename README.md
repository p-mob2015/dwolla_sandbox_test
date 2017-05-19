# dwolla_sandbox_test
Test project for verifying Dwolla transaction process and feasibility

## Relevant files
### config/initializers/dwolla.rb
### app/models/token_data.rb
### app/models/concerns/token_concern.rb
### app/services/dwolla.rb

## Test scripts in "Rails console"
### dwolla = Dwolla.new
### dwolla.create_customer
### dwolla.register_funding_source
### dwolla.initiate_transfer
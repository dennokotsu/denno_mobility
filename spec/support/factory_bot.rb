# Enable to write only `create` instead of `FactoryBot.create`.
# ref. https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#configure-your-test-suite
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

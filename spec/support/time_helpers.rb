# For `travel_to`, `travel_back`, `freeze_time` and etc.
# ref.
#   https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html
#   https://techracho.bpsinc.jp/penguin10/2018_12_25/67780
RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
end

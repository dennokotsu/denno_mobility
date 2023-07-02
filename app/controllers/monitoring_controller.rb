# :nocov:
class MonitoringController < ActionController::Base
  def health
    render status: 200, plain: "OK"
  end
end
# :nocov:

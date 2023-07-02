# :nocov:
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      Rails.logger.debug "ApplicationCable Connection connect()"
      self.current_user = find_verified_user
      Rails.logger.debug "ApplicationCable `current_user.id`: #{current_user.id}"
    end

    private

      def find_verified_user
        authentication_token = User.token_digest(cookies[:user_authentication_token])
        User.find_by(authentication_token:)&.then { return _1 }
        reject_unauthorized_connection
      end
  end
end
# :nocov:

class ApplicationController < ActionController::Base
  before_action :current_user
  before_action :current_company
  before_action :require_sign_in!
  before_action :active_page
  helper_method :signed_in?

  protect_from_forgery with: :exception

  def sign_in(user)
    authentication_token = User.new_authentication_token
    cookies.permanent[:user_authentication_token] = authentication_token
    authentication_data = {
      "user_agent" => request.env["HTTP_USER_AGENT"],
      "remote_ip" => request.remote_ip
    }
    user.update!(
      authentication_token: User.token_digest(authentication_token),
      authenticated_at: Time.zone.now,
      authentication_data:
    )
    @current_user = user
  end

  def sign_out
    cookies.delete(:user_authentication_token)
  end

  def signed_in?
    @current_user.present?
  end

  def not_found
    Rails.logger.warn "意図的に404ページへ遷移させる"
    raise ActionController::RoutingError, "Not Found"
  end

  def get_setting(setting_name)
    return {} unless signed_in?

    company_settings = @current_company[:setting_data]
    if company_settings.blank?
      Rails.logger.error "Common:Setting 設定の取得に失敗、中身が空等... company_code:#{@current_company[:company_code]} setting_name:#{setting_name}" # rubocop:disable Layout/LineLength
      return {}
    end

    company_settings[setting_name].present? ? company_settings[setting_name] : {}
  end

  private

    def current_user
      authentication_token = User.token_digest(cookies[:user_authentication_token])
      @current_user ||= User.find_by(authentication_token:)
      return unless @current_user.present?

      @is_admin = @current_user[:role] == USER_ROLE_ADMIN
      return unless @is_admin
      # 管理者は一定時間で強制ログアウト
      return unless Time.zone.now.to_i - @current_user[:authenticated_at].to_i > 1.day

      sign_out
      @current_user = nil
    end

    def current_company
      return unless @current_user.present?

      @current_company ||= Company.find_by(id: @current_user[:company_id])
    end

    def active_page
      @active_page = ""
      controller = params[:controller]
      action = params[:action]
      if controller == "chats" && action == "index"
        @active_page = "chats"
      elsif controller == "chats"
        @active_page = "chat"
      elsif controller == "slips" && action == "new"
        @active_page = "new_slip"
      elsif controller == "slips"
        @active_page = "slips"
      elsif controller.include?("settings/")
        @active_page = "settings"
      end
    end

    def require_sign_in!
      redirect_to login_path unless signed_in?
    end
end

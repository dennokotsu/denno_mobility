class SessionsController < ApplicationController
  skip_before_action :require_sign_in!, only: %i[new create]
  before_action :set_user, only: [:create]

  def new
    sign_out
  end

  def create
    if @user.authenticated_locked
      # アカウントロック判定
      flash.now[:danger] = "アカウントがロックされています"
      render :new, status: :unprocessable_entity and return
    elsif @user.authenticate(session_params[:password])
      flash.now[:password] = session_params[:password]
      sign_in(@user)
      @user.authenticated_lock_unlock
      redirect_to chats_url, status: :see_other
    else
      Rails.logger.warn "ログイン認証失敗 #{session_params[:company_code]}:#{session_params[:identifier]}"
      flash.now[:danger] = "ログインに失敗しました"
      @user.authenticated_lock_countup if @user[:role] == USER_ROLE_USER
      render :new, status: :unprocessable_entity
    end
  end

  private

    def set_user
      flash.now[:company_code] = session_params[:company_code]
      flash.now[:identifier] = session_params[:identifier]

      company = Company.find_by!(company_code: session_params[:company_code])
      @user = User.find_by!(company_id: company[:id], identifier: session_params[:identifier])
    rescue StandardError
      Rails.logger.warn "ログインユーザー情報取得不可 #{session_params[:company_code]}:#{session_params[:identifier]}"
      flash.now[:danger] = "ログインに失敗しました"
      render :new, status: :unprocessable_entity
    end

    # 許可するパラメータ
    def session_params
      params.require(:session).permit(:company_code, :identifier, :password, :token_2fa)
    end
end

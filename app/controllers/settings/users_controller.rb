class Settings::UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]

  def index
    @users = User.where(company_id: @current_user[:company_id], disabled: false).order(role: :desc, id: :asc)
  end

  def new
    @user = User.new
    set_user_attribute_settings
    set_user_attributes
  end

  def edit; end

  def create
    @user = User.new(user_params)
    @user[:company_id] = @current_company[:id]

    @user.valid?

    set_user_attribute_settings

    @user_attributes = create_user_attributes

    @user[:data] = {}
    # 任意属性
    @user[:data]["attribute"] = @user_attributes
    # ステータス
    @user[:data]["status"] = ""
    # 座標
    position = {}
    position["latitude"] = nil
    position["longitude"] = nil
    @user[:data]["position"] = position

    if @user.save
      redirect_to settings_users_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @user[:identifier] = user_params[:identifier]
    @user[:name] = user_params[:name]

    @user[:role] =
      if @current_user[:role] == USER_ROLE_ADMIN
        user_params[:role]
      else
        USER_ROLE_USER
      end

    @user.valid?

    attach_avatar

    @user_attributes = create_user_attributes
    @user[:data] = {} unless @user[:data].is_a?(Hash)
    @user[:data]["attribute"] = @user_attributes

    if @user.errors.present?
      render :edit, status: :unprocessable_entity
      return
    end

    if @user.update(user_params)
      @user.authenticated_lock_unlock if params[:user]["authenticated_unlock"].present?

      if @current_user[:role] == USER_ROLE_ADMIN
        redirect_to settings_users_path, status: :see_other
      else
        redirect_to settings_lists_path, status: :see_other
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    not_found unless @is_admin

    if @user[:id] == @current_user[:id]
      flash.now[:danger] = "自分は削除できません"
      render :edit, status: :unprocessable_entity
      return
    end

    slips =
      Slip.where(company_id: @current_company[:id], rep_user_id: @user[:id]).where.not(status: SLIP_STATUS_COMPLETE)
    if slips.present?
      flash.now[:danger] = "完了状態以外の伝票が割り当てられているユーザーは削除できません。"
      render :edit, status: :unprocessable_entity
      return
    end

    @user[:identifier] = @user[:identifier] + Digest::SHA256.hexdigest(rand(99_999).to_s)
    @user[:name] = "[削除済] #{@user[:name]}"
    @user[:authentication_token] = Digest::SHA256.hexdigest(rand(99_999).to_s)
    @user[:disabled] = true
    @user.save

    GroupUser.where(user_id: @user[:id]).delete_all

    redirect_to settings_users_path, status: :see_other
  end

  private

    def set_user
      @user = User.find_by(id: params[:id])
      not_found if @user.blank?

      # 表示権限チェック
      case @current_user[:role]
      when USER_ROLE_ADMIN
        not_found if @current_user[:company_id] != @user[:company_id]
      when USER_ROLE_USER
        not_found if @current_user[:id] != @user[:id]
      else
        not_found
      end

      # 属性値の組み立て
      set_user_attribute_settings
      set_user_attributes
    end

    # 設定ファイルからの属性値の設定を組み立て
    def set_user_attribute_settings
      @user_attribute_settings = get_setting("user_attribute")
    end

    # ユーザー情報から属性の組み立て
    def set_user_attributes
      @user_attributes = {}

      user_attributes = {}
      user_attributes = @user[:data]["attribute"] if @user[:data].present? && @user[:data]["attribute"].present?

      # 表示値の設定
      @user_attribute_settings.each do |setting|
        @user_attributes[setting["name"]] =
          if user_attributes[setting["name"]].present?
            case setting["type"]
            when "date", "datetime"
              DateTime.parse(user_attributes[setting["name"]])
            else
              user_attributes[setting["name"]]
            end
          elsif setting["default"].present?
            case setting["type"]
            when "date", "datetime"
              DateTime.parse(setting["default"])
            else
              setting["default"]
            end
          end
      end
    end

    def create_user_attributes
      user_attribute = {}

      @user_attribute_settings.each do |setting|
        if params[:user][setting["name"]].present?
          # リクエストパラメータでは文字列になってしまっているのでtypeに応じた型ににしてyamlから取得した設定と合わせる。
          user_attribute[setting["name"]] =
            case setting["type"]
            when "number"
              params[:user][setting["name"]].to_i
            when "date", "datetime"
              DateTime.parse(params[:user][setting["name"]])
            else
              params[:user][setting["name"]]
            end
        elsif setting["require"]
          @user.errors.add(setting["display_name"], "を入力して下さい。")
        end
      end

      user_attribute
    end

    def attach_avatar
      return unless params[:user][:avatar].present?

      unless params[:user][:avatar].content_type.in?(["image/jpeg", "image/png"])
        @user.errors.add("ユーザー画像", "はjpgかpngのみ登録可能です。")
        return
      end
      if params[:user][:avatar].size > (1024 * 1024)
        @user.errors.add("ユーザー画像", "は1MB以下のみ登録可能です。")
        return
      end

      @user.avatar.attach(params[:user][:avatar])
    end

    def user_params
      params.require(:user).permit(
        :name,
        :identifier,
        :role,
        :password,
        :password_confirmation
      )
    end
end

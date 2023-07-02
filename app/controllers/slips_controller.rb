class SlipsController < ApplicationController
  before_action :init
  before_action :set_rep_list, only: %i[new edit create update]
  before_action :set_rep_list_with_deleted, only: %i[index show]
  before_action :set_slip, only: %i[show edit update destroy]

  def index
    @target_day =
      if params["target_day"].present?
        Time.zone.parse(params["target_day"])
      else
        Time.zone.today
      end

    start_time = @target_day.beginning_of_day
    end_time = @target_day.end_of_day

    # 対象日時の伝票一覧を取得
    if @is_admin
      origin_slips =
        Slip
          .where(company_id: @current_company[:id], targeted_at: start_time..end_time)
          .order(targeted_at: :ASC)
    else
      origin_slips =
        Slip
          .where(company_id: @current_company[:id], targeted_at: start_time..end_time, rep_user_id: @current_user[:id])
          .order(targeted_at: :ASC)
    end

    # 表示用の時間帯ごとの伝票リストを作成
    target_time = @target_day.beginning_of_day
    @display_slips = {}
    while target_time < end_time
      slips = []
      origin_slips.each do |origin_slip|
        if origin_slip[:targeted_at] >= target_time && origin_slip[:targeted_at] < (target_time + 1.hours)
          slips.push(origin_slip)
        end
      end
      @display_slips[target_time.strftime("%H:%M")] = slips
      target_time += 1.hours
    end
  end

  def show
    @disabled = true
    set_slip_attributes
  end

  def new
    # 管理者以外は新規伝票作成はNG
    unless @is_admin
      redirect_to slips_path, status: :see_other
      return
    end

    @slip = Slip.new
    @slip[:data] = {}
    @disabled = false

    set_slip_attributes
  end

  def edit
    @disabled = @is_admin ? false : true
    set_slip_attributes
  end

  def create
    unless @is_admin
      # Rails.logger.warn "SlipsController:create 管理者以外は新規伝票は作成不可"
      redirect_to slips_path, status: :see_other
      return
    end

    @slip = Slip.new(slip_params)
    @slip[:company_id] = @current_company[:id]
    @slip[:created_user_id] = @current_user[:id]
    @slip[:updated_user_id] = @current_user[:id]

    @slip.valid?

    @slip_attributes = create_slip_attributes
    @slip[:data] = {}
    # 任意属性
    @slip[:data]["attribute"] = @slip_attributes
    # ステータス
    @slip[:status] = SLIP_STATUS_UNASSIGNED

    if @slip.errors.present?
      # 登録画面再表示用の値設定
      render :new, status: :unprocessable_entity
      return
    end

    if @slip.save
      if @slip[:rep_user_id].present?
        # 担当者が割り当てられている場合、割当のメッセージを作成する。
        create_slip_message
      end

      redirect_to slips_path(target_day: @slip[:targeted_at].strftime("%Y-%m-%d")), status: :see_other
    else
      Rails.logger.error "SlipsController 新規伝票登録エラー : #{@slip.errors}"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    #
    # 伝票ステータス更新処理
    # ステータスが指定されている場合はステータスの更新のみ行う
    #
    if params[:status].present?
      case params[:status]
      when "accept"
        @slip[:status] = SLIP_STATUS_ACCEPT
        @slip[:updated_user_id] = @current_user[:id]
      when "reject"
        @slip[:status] = SLIP_STATUS_REJECT
        @slip[:updated_user_id] = @current_user[:id]
      when "pickup"
        @slip[:status] = SLIP_STATUS_PICKUP
        @slip[:updated_user_id] = @current_user[:id]
        @slip[:data]["pickup_start_time"] = Time.zone.now
      when "deliver"
        @slip[:status] = SLIP_STATUS_DELIVER
        @slip[:updated_user_id] = @current_user[:id]
        @slip[:data]["pickup_time"] = Time.zone.now
      when "complete"
        error_message = []
        error_message.push("乗車距離を入力して下さい。") if params[:slip][:get_off_distance].blank?
        error_message.push("収受運賃を入力して下さい。") if params[:slip][:get_off_payment].blank?
        if error_message.present?
          flash[:warning] = error_message.join("<br>")
          redirect_to slip_path(@slip)
          return
        end

        @slip[:status] = SLIP_STATUS_COMPLETE
        @slip[:updated_user_id] = @current_user[:id]
        @slip[:data]["getoff_time"] = Time.zone.now
        @slip[:data]["distance"] = params[:slip][:get_off_distance]
        @slip[:data]["payment"] = params[:slip][:get_off_payment]
      end

      @slip.save
      redirect_to slip_path(@slip), status: :see_other
      return
    end

    #
    # 伝票情報更新処理
    #
    before_slip = @slip.dup

    @slip[:name] = slip_params[:name]
    @slip.valid?

    @slip_attributes = create_slip_attributes
    @slip[:data] = {} unless @slip[:data].is_a?(Hash)
    @slip[:data]["attribute"] = @slip_attributes
    @slip[:updated_user_id] = @current_user[:id]

    if @slip.errors.present?
      render :edit, status: :unprocessable_entity
      return
    end

    # 受領拒否状態で再度同じ担当者を割り当てた場合、確認中に戻す。
    if @slip[:status] == SLIP_STATUS_REJECT && @slip[:rep_user_id] == slip_params[:rep_user_id].to_i
      @slip[:status] = SLIP_STATUS_ASSIGNED
    end

    if @slip.update(slip_params)
      if @slip[:rep_user_id].present? && @slip[:rep_user_id] != before_slip[:rep_user_id]
        # 担当者変更になっている場合は、割当のメッセージを作成する。
        create_slip_message
      end

      redirect_to slips_path(target_day: @slip[:targeted_at].strftime("%Y-%m-%d")), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    target_day = @slip[:targeted_at].strftime("%Y-%m-%d")
    unless @is_admin
      Rails.logger.warn "SlipsController:destory 管理者以外は削除不可"
      redirect_to slips_path(target_day:), status: :see_other
      return
    end
    @slip.destroy
    redirect_to slips_path(target_day:), status: :see_other
  end

  private

    def init
      set_slip_attribute_settings
    end

    def set_rep_list
      @rep_list = {}
      @rep_list_id = {}
      users = User.where(company_id: @current_user[:company_id], role: USER_ROLE_USER, disabled: false).order(id: :ASC)
      users.each do |user|
        @rep_list[user["name"]] = user[:id]
        @rep_list_id[user[:id]] = user["name"]
      end
    end

    def set_rep_list_with_deleted
      @rep_list = {}
      @rep_list_id = {}
      users = User.where(company_id: @current_user[:company_id], role: USER_ROLE_USER).order(id: :ASC)
      users.each do |user|
        @rep_list[user["name"]] = user[:id]
        @rep_list_id[user[:id]] = user["name"]
      end
    end

    def set_slip
      @slip = Slip.find_by(id: params[:id])
      return redirect_to slips_path, status: :see_other if @slip.blank?

      # 表示権限チェック
      case @current_user[:role]
      when USER_ROLE_ADMIN
        return redirect_to slips_path, status: :see_other if @current_user[:company_id] != @slip[:company_id]
      when USER_ROLE_USER
        return redirect_to slips_path, status: :see_other if @current_user[:id] != @slip[:rep_user_id]
      else
        return redirect_to slips_path, status: :see_other
      end

      # 表示用データ
      return unless @slip[:data].present?

      @pickup_start_time = @slip[:data]["pickup_start_time"].then { _1.present? ? DateTime.parse(_1) : nil }
      @pickup_time = @slip[:data]["pickup_time"].then { _1.present? ? DateTime.parse(_1) : nil }
      @getoff_time = @slip[:data]["getoff_time"].then { _1.present? ? DateTime.parse(_1) : nil }
    end

    def slip_params
      params.require(:slip).permit(
        :name,
        :targeted_at,
        :rep_user_id
      )
    end

    # 設定ファイルからの属性値の設定を組み立て
    def set_slip_attribute_settings
      @slip_attribute_settings = get_setting("slip_attribute")

      # 任意項目の編集可否の設定
      @attribute_disabled = {}
      @slip_attribute_settings.each do |slip_attribute_setting|
        disabled = true
        if action_name.in?(%w[new create update])
          disabled = false
        elsif action_name == "edit"
          disabled = false if @is_admin
          disabled = false if slip_attribute_setting["user_edit"]
        end
        @attribute_disabled[slip_attribute_setting["name"]] = disabled
      end
    end

    # 伝票情報から属性の組み立て
    def set_slip_attributes
      @slip_attributes = {}

      slip_attributes = {}
      slip_attributes = @slip[:data]["attribute"] if @slip[:data].present? && @slip[:data]["attribute"].present?

      # 表示値の設定
      @slip_attribute_settings.each do |setting|
        @slip_attributes[setting["name"]] =
          if slip_attributes[setting["name"]].present?
            case setting["type"]
            when "date", "datetime"
              DateTime.parse(slip_attributes[setting["name"]])
            else
              slip_attributes[setting["name"]]
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

    def create_slip_attributes
      slip_attribute = {}

      @slip_attribute_settings.each do |setting|
        if params[:slip][setting["name"]].present?
          # リクエストパラメータでは文字列になってしまっているのでtypeに応じた型ににしてyamlから取得した設定と合わせる。
          slip_attribute[setting["name"]] =
            case setting["type"]
            when "number"
              params[:slip][setting["name"]].to_i
            when "date", "datetime"
              DateTime.parse(params[:slip][setting["name"]])
            else
              params[:slip][setting["name"]]
            end
        elsif setting["require"]
          @slip.errors.add(setting["display_name"], "を入力して下さい。")
        end
      end

      slip_attribute
    end

    # 伝票割当のメッセージを作成
    def create_slip_message
      return if @current_user[:id] == @slip[:rep_user_id]

      message = Message.new
      message[:company_id] = @current_company[:id]
      message[:from_user_id] = @current_user[:id]
      message[:to_user_id] = @slip[:rep_user_id]

      message[:data] = {}
      message[:data]["message"] = "伝票：「#{@slip[:name]}」が割当されました。"
      message[:data]["slip_id"] = @slip[:id]

      message.save

      # 伝票の状態を確認中にする
      @slip.update(status: SLIP_STATUS_ASSIGNED)

      # メッセージ更新
      user_room = "#{CHAT_CHANNEL_ROOM_PREFIX}f#{@current_user[:id]}_t#{@slip[:rep_user_id]}"
      ActionCable.server.broadcast(user_room, {})
    end
end

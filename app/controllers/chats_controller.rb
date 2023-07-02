class ChatsController < ApplicationController
  def index
    users =
      if @is_admin || get_setting("chat_type") == "all"
        User
          .where(company_id: @current_user[:company_id], disabled: false)
          .where.not(id: @current_user[:id])
          .order(id: :desc)
      else
        User
          .where(company_id: @current_user[:company_id], role: USER_ROLE_ADMIN, disabled: false)
          .where.not(id: @current_user[:id])
          .order(id: :desc)
      end

    #
    # 全体チャット情報構築
    #
    @last_all_message =
      Message.where(company_id: @current_company[:id], to_user_id: nil, group_id: nil, disabled: false).last
    if @last_all_message.present?
      @last_all_message_user = User.find_by(id: @last_all_message[:from_user_id])
      @last_all_message_time =
        if @last_all_message[:created_at] < Time.zone.now.beginning_of_day
          @last_all_message[:created_at].strftime("%m/%d")
        else
          "#{((Time.zone.now - @last_all_message[:created_at]) / 60).round}分前"
        end
    end

    # 未読件数
    read_id = @current_user[:data]["read_all_message_id"].present? ? @current_user[:data]["read_all_message_id"] : 0
    unread_all_count =
      Message
        .where(company_id: @current_company[:id], to_user_id: nil, group_id: nil, disabled: false)
        .where("id > ?", read_id)
        .size
    @unread_all_count = unread_all_count < 99 ? unread_all_count : 99

    #
    # 個別チャット情報構築
    #
    # IDをキーにしたユーザー情報
    @users = {}
    users.each do |user|
      @users[user[:id]] = user
    end

    # ユーザー毎の最終メッセージと未読件数を取得
    @last_user_message = {}
    @unread_count = {}
    users.each do |user|
      last_message =
        Message
          .where(company_id: @current_user[:company_id], disabled: false)
          .merge(
          Message.where(from_user_id: @current_user[:id], to_user_id: user[:id])
            .or(Message.where(from_user_id: user[:id], to_user_id: @current_user[:id]))
        ).last
      @last_user_message[user[:id]] = last_message

      unread_count =
        Message
          .where(
            company_id: @current_company[:id],
            from_user_id: user[:id],
            to_user_id: @current_user[:id],
            read: false
          )
          .count
      @unread_count[user[:id]] = unread_count < 99 ? unread_count : 99
    end

    # ユーザー毎の最終会話時間を表示用によろしく変換
    @last_chat_times = {}
    users.each do |user|
      next unless @last_user_message[user[:id]].present?

      @last_chat_times[user[:id]] =
        if @last_user_message[user[:id]][:created_at] < Time.zone.now.beginning_of_day
          # 最終メッセージが前日以前の場合、日時を設定
          @last_user_message[user[:id]][:created_at].strftime("%m/%d")
        else
          # 最終メッセージが当日の場合、何分前かかを表示
          "#{((Time.zone.now - @last_user_message[user[:id]][:created_at]) / 60).round}分前"
        end
    end

    # 表示順番制御用に最終会話時間順にソートされたユーザーIDのリストを作成する
    @sorted_user_ids = []
    last_message_times = {}

    users.each do |user|
      last_message_times[user[:id]] =
        if @last_user_message[user[:id]].present?
          @last_user_message[user[:id]][:created_at].to_i
        else
          0
        end
    end

    last_message_times = last_message_times.sort_by { |_key, value| value }.reverse.to_h
    last_message_times.each do |key, _value|
      @sorted_user_ids.push(key)
    end

    #
    # グループチャット情報構築
    #
    group_ids = GroupUser.where(company_id: @current_company[:id], user_id: @current_user[:id]).pluck(:group_id)
    @groups = Group.where(id: group_ids)
    return unless @groups.present?

    @unread_group_count = {}
    @last_group_messages = {}
    @last_group_messages_user = {}
    @last_group_message_times = {}

    @groups.each do |group|
      # 未読件数
      read_id = @current_user[:data]&.dig("read_group_message_id", group[:id].to_s).then { _1.present? ? _1 : 0 }
      unread_group_count =
        Message
          .where(company_id: @current_company[:id], group_id: group[:id])
          .where("id > ?", read_id)
          .size
      @unread_group_count[group[:id]] = unread_group_count < 99 ? unread_group_count : 99

      # 最終メッセージ
      last_message = Message.where(company_id: @current_company[:id], group_id: group[:id], disabled: false).last
      next unless last_message.present?

      @last_group_messages[group[:id]] = last_message
      @last_group_messages_user[group[:id]] = User.find(last_message[:from_user_id])
      @last_group_message_times[group[:id]] =
        if last_message[:created_at] < Time.zone.now.beginning_of_day
          last_message[:created_at].strftime("%m/%d")
        else
          "#{((Time.zone.now - last_message[:created_at]) / 60).round}分前"
        end
    end
  end

  def show
    if params[:id] == "all"
      # 全体チャット
      @is_all_chat = true
      @title = "全体チャット"
      @message_url = message_path("all")
      @chat_channel_room = "all_#{@current_company[:id]}"
    elsif params[:id] == "group"
      # グループチャット
      @is_group_chat = true
      @group = Group.find_by(id: params[:group_id], company_id: @current_company[:id])
      return not_found if @group.nil?

      @title = @group[:name]
      @message_url = message_path(id: "group", group_id: @group[:id])
      @chat_channel_room = "group_#{@group[:id]}"
    else
      # 個別チャット
      @user = User.find_by(id: params[:id], disabled: false)

      # 会話対象のユーザと自ユーザーのチェック
      if @user.blank? || @user[:company_id] != @current_user[:company_id]
        # ユーザーが存在しないか、別事業者のユーザーを指定しているのでチャット一覧へ遷移させる
        redirect_to chats_url
        return
      end

      @title = @user[:name]
      @message_url = message_path(@user)
      @chat_channel_room = "f#{@user[:id]}_t#{@current_user[:id]}"
    end

    # フッターの個別チャットリンクから最後にチャットしたユーザーにアクセスできるようにcookieに記録しておく
    cookies[:last_chat_path] =
      if params[:id] == "group"
        chat_path("group", group_id: params[:group_id])
      else
        chat_path(params[:id])
      end

    # 表示されるメッセージ一覧は message_controller.rb へ移動して遅延読み込みさせてる
  end

  private

    # 該当ユーザーとの距離を算出
    def calc_distance(user)
      return "-" if @current_user[:position].blank? || user[:position].blank?

      lat1 = @current_user[:position].x
      lng1 = @current_user[:position].y
      lat2 = user[:position].x
      lng2 = user[:position].y
      distance = Common::Geo.calc_distance(lat1, lng1, lat2, lng2)
      (distance / 1000).round(1)
    end

    # 該当ユーザーの方角を算出
    def calc_angle(user)
      return nil if @current_user[:position].blank? || user[:position].blank?

      lat1 = @current_user[:position].x
      lng1 = @current_user[:position].y
      lat2 = user[:position].x
      lng2 = user[:position].y
      Common::Geo.calc_angle(lat1, lng1, lat2, lng2).ceil(0)
    end

    helper_method :calc_distance
    helper_method :calc_angle
end

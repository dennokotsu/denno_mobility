class MessagesController < ApplicationController
  def show
    if params[:id] == "all"
      # 全体チャットパターン
      @is_all_chat = true
      messages =
        Message
          .where(company_id: @current_company[:id], to_user_id: nil, group_id: nil, disabled: false)
          .order(id: :desc)
          .limit(100)

      @users = {}
      users = User.where(company_id: @current_company[:id])
      users.each do |user|
        @users[user[:id]] = user
      end
    elsif params[:id] == "group"
      # グループチャットパターン
      @group = Group.find_by(id: params[:group_id], company_id: @current_company[:id])
      return not_found if @group.blank?

      @is_group_chat = true
      messages =
        Message
          .where(company_id: @current_company[:id], to_user_id: nil, group_id: params[:group_id], disabled: false)
          .order(id: :desc)
          .limit(100)

      @users = {}
      users = User.where(company_id: @current_company[:id])
      users.each do |user|
        @users[user[:id]] = user
      end
    else
      # 個別チャットパターン
      @user = User.find_by(id: params[:id])
      return not_found if @user.blank?

      messages =
        Message
          .where(company_id: @current_company[:id], disabled: false)
          .merge(
          Message.where(from_user_id: @current_user[:id], to_user_id: @user[:id])
            .or(Message.where(from_user_id: @user[:id], to_user_id: @current_user[:id]))
        )
          .order(id: :desc)
          .limit(100)
    end

    # IDの降順でソートし直しておく
    @messages = messages.sort { |a, b| a[:id] <=> b[:id] }

    # 取得したところまでは既読にする
    if @user.present? && @messages.present?
      last_message_id = @messages.last[:id]
      Message
        .where(
          company_id: @current_company[:id],
          from_user_id: @user[:id],
          to_user_id: @current_user[:id],
          read: false,
          id: ..last_message_id
        )
        .update_all(read: true)
    end

    # 伝票情報を取得
    slip_ids = []
    @messages.each do |message|
      slip_ids.push(message[:data]["slip_id"]) if message[:data].present? && message[:data]["slip_id"].present?
    end

    @slips_info = {}
    if slip_ids.present?
      slips = Slip.where(id: slip_ids)
      slips.each do |slip|
        @slips_info[slip[:id]] = slip
      end
    end

    # 全体とグループチャットの既読メッセージIDを記録
    return unless @messages.present?

    if @is_all_chat
      last_message = @messages.last
      @current_user[:data]["read_all_message_id"] = last_message[:id]
      @current_user.save
    elsif @is_group_chat
      last_message = @messages.last
      @current_user[:data]["read_group_message_id"] = {} if @current_user[:data]["read_group_message_id"].blank?
      @current_user[:data]["read_group_message_id"][@group[:id]] = last_message[:id]
      @current_user.save
    end
  end

  def update
    if params[:id] == "all"
      nil # Do nothing
    elsif params[:id] == "group"
      # 対象グループチェック
      @group = Group.find_by(id: params[:group_id], company_id: @current_company[:id])
      return not_found if @group.blank?
    else
      # 会話対象のユーザのチェック
      @user = User.find_by(id: params[:id], company_id: @current_company[:id])
      return not_found if @user.blank?
    end

    # 本文も画像もないメッセージは無視
    return if params[:chat_message][:message].blank? && params[:chat_message][:picture].blank?

    message = Message.new
    message[:company_id] = @current_user[:company_id]
    message[:from_user_id] = @current_user[:id]
    message[:to_user_id] = @user.present? ? @user[:id] : nil
    message[:group_id] = @group.present? ? @group[:id] : nil
    message[:data] = {}

    message[:data]["message"] = params[:chat_message][:message] if params[:chat_message][:message].present?

    success = true
    if params[:chat_message][:picture].present?
      # 画像が登録可能かチェック
      error_message = []
      unless params[:chat_message][:picture].content_type.in?(["image/jpeg", "image/png"])
        error_message.push("添付画像はjpgかpngのみ登録可能です")
      end
      error_message.push("添付画像は5MB以下のみ登録可能です") if params[:chat_message][:picture].size > (1024 * 1024 * 5)
      # 問題なければメッセージに画像を紐づけ
      if error_message.present?
        flash[:danger] = error_message.join("<br>").html_safe
        success = false
      else
        message.picture.attach(params[:chat_message][:picture])
      end
    end

    if success
      message.save
      @messages = [message]
    end

    # 画面更新
    if @user.present?
      # 個別メッセージ更新
      my_room = "#{CHAT_CHANNEL_ROOM_PREFIX}f#{@user[:id]}_t#{@current_user[:id]}"
      user_room = "#{CHAT_CHANNEL_ROOM_PREFIX}f#{@current_user[:id]}_t#{@user[:id]}"
      ActionCable.server.broadcast(my_room, {})
      ActionCable.server.broadcast(user_room, {})
    elsif @group.present?
      # グループメッセージ更新
      group_room = "#{CHAT_CHANNEL_ROOM_PREFIX}group_#{@group[:id]}"
      ActionCable.server.broadcast(group_room, {})
    else
      # 全体メッセージ更新
      all_room = "#{CHAT_CHANNEL_ROOM_PREFIX}all_#{@current_company[:id]}"
      ActionCable.server.broadcast(all_room, {})
    end
  end
end

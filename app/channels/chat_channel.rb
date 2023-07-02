# :nocov:
class ChatChannel < ApplicationCable::Channel
  def subscribed
    # Rails.logger.debug "ChatChannel params : #{params.inspect}"
    return if current_user.company.id != params[:company_id].to_i

    stream_from CHAT_CHANNEL_ROOM_PREFIX + params[:room]
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
# :nocov:

class Api::GeoController < ApplicationController
  # アクセスしてきたユーザーの座標情報を更新
  def create
    return render json: { success: false } if params[:lat].blank? || params[:lng].blank?

    # Rails.logger.debug "座標更新 #{@current_user[:name]} lat:#{params[:lat]} lng:#{params[:lng]}"
    @current_user[:position] = "POINT(#{params[:lat]} #{params[:lng]})"
    @current_user.save
    render json: { success: true }
  end
end

class SidebarController < ApplicationController
  def index
    @statuses = get_setting("user_statuses")

    return unless params[:status].present?

    @current_user[:data]["status"] = params[:status]
    @current_user.save
  end

  # def show
  # end

  # def new
  # end

  # def edit
  # end

  # def create
  # end

  # def update
  # end

  # def destroy
  # end
end

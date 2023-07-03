class Settings::GroupsController < ApplicationController
  before_action :roll_check
  before_action :set_users, only: %i[new edit update destroy]

  def index
    @groups = Group.where(company_id: @current_company[:id]).order(id: :asc)
    @group_users_text = {}
    @groups.each do |group|
      group_user_ids = GroupUser.where(company_id: @current_company[:id], group_id: group[:id]).pluck(:user_id)
      users = User.where(id: group_user_ids)
      @group_users_text[group[:id]] = users.pluck(:name).join(", ")
    end
  end

  def new
    @group = Group.new
    @target_user_ids = []
  end

  def edit
    @group = Group.find_by(id: params[:id], company_id: @current_company[:id])
    @target_user_ids = GroupUser.where(company_id: @current_company[:id], group_id: params[:id]).pluck(:user_id)
  end

  def create
    @group = Group.new
    @group[:company_id] = @current_company[:id]
    @group[:name] = params[:group][:name]

    @group.valid?

    if @group.errors.present?
      set_users
      @target_user_ids = params[:target_user_ids].present? ? params[:target_user_ids].map(&:to_i) : []
      render :new, status: :unprocessable_entity
      return
    end

    @group.save

    if params[:target_user_ids].present?
      params[:target_user_ids].each do |target_user_id|
        group_user = GroupUser.new
        group_user[:company_id] = @current_company[:id]
        group_user[:group_id] = @group[:id]
        group_user[:user_id] = target_user_id
        group_user.save
      end
    end

    redirect_to settings_groups_path, status: :see_other
  end

  def update
    @group = Group.find_by(id: params[:id], company_id: @current_company[:id])

    @group[:name] = params[:group][:name]
    @group.valid?

    if @group.errors.present?
      get_target_users
      @target_user_ids = params[:target_user_ids].present? ? params[:target_user_ids].map(&:to_i) : []
      render :edit, status: :unprocessable_entity
      return
    end

    @group.update(name: params[:group][:name])

    target_user_ids = params[:target_user_ids]
    group_users = GroupUser.where(company_id: @current_company[:id], group_id: params[:id])
    group_user_ids = group_users.pluck(:user_id)

    if target_user_ids.present?
      # 含まれてないのは消す
      group_users.each do |group_user|
        group_user.delete unless target_user_ids.include?(group_user[:user_id].to_s)
      end

      # 新規で作成されたのは作る
      target_user_ids.each do |target_user_id|
        next if group_user_ids.include?(target_user_id.to_i)

        group_user = GroupUser.new
        group_user[:company_id] = @current_company[:id]
        group_user[:group_id] = params[:id]
        group_user[:user_id] = target_user_id
        group_user.save
      end
    else
      # 登録ユーザーが以内場合対象グループの設定を全消し
      GroupUser.where(company_id: @current_company[:id], group_id: params[:id]).delete_all
    end

    redirect_to settings_groups_path, status: :see_other
  end

  def destroy
    GroupUser.where(company_id: @current_company[:id], group_id: params[:id]).delete_all
    Group.find_by(id: params[:id], company_id: @current_company[:id]).delete

    redirect_to settings_groups_path, status: :see_other
  end

  private

    def roll_check
      not_found unless @is_admin
    end

    def set_users
      @users = User.where(company_id: @current_company[:id], disabled: false).order(role: :ASC, id: :ASC)
    end
end

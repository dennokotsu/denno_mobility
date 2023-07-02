require "rails_helper"

RSpec.describe Settings::UsersController, type: :request do
  sign_in_user

  describe "GET /settings/users" do
    before { get settings_users_path }

    it { expect(response.status).to eq 200 }
  end

  describe "GET /settings/users/new" do
    before { get new_settings_user_path }

    it { expect(response.status).to eq 200 }
  end

  describe "GET /settings/users/:id/edit" do
    before { get edit_settings_user_path(current_user) }

    it { expect(response.status).to eq 200 }
  end

  describe "PUT /settings/users/:id" do
    before { @user = current_user }
    subject do
      user = {
        identifier: current_user.identifier,
        name: "Updated Name"
      }
      user.merge!(company_setting_data_user_attribute_required_defaults(current_company))
      put settings_user_path(current_user), params: { user: }
    end

    it do
      subject
      @user.reload
      expect(@user.name).to eq "Updated Name"
    end
  end
end

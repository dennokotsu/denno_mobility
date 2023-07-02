require "rails_helper"

RSpec.describe Settings::UsersController, type: :request do
  sign_in_user_admin

  describe "POST /settings/users" do
    let(:name) { "Name" }

    subject do
      user = {
        identifier: "new-user",
        password: "password", password_confirmation: "password",
        name:,
        role: USER_ROLE_USER
      }
      user.merge!(company_setting_data_user_attribute_required_defaults(current_company))
      post settings_users_path, params: { user: }
    end

    it { expect { subject }.to change { User.count }.by 1 }

    it do
      subject
      expect(response.status).to eq 303
    end

    context "with invalid params" do
      let(:name) { "" }

      it do
        subject
        expect(response.status).to eq 422
      end
    end
  end

  describe "PUT /settings/users/:id" do
    before { @user = current_user }

    let(:role) { USER_ROLE_ADMIN }

    subject do
      user = {
        identifier: current_user.identifier,
        name: "Updated Name",
        role:
      }
      user.merge!(company_setting_data_user_attribute_required_defaults(current_company))
      put settings_user_path(current_user), params: { user: }
    end

    it do
      subject
      @user.reload
      expect(@user.name).to eq "Updated Name"
    end

    context "role is empty" do
      let(:role) { nil }

      it do
        subject
        expect(response.status).to eq 422
      end
    end
  end

  describe "PUT /settings/users/:id" do
    before { @user = current_user }

    subject do
      user = {
        identifier: current_user.identifier,
        name: "Updated Name",
        role: USER_ROLE_ADMIN,
        avatar: fixture_file_upload("test.gif")
      }
      user.merge!(company_setting_data_user_attribute_required_defaults(current_company))
      put settings_user_path(current_user), params: { user: }
    end

    it do
      subject
      @user.reload
      expect(response.status).to eq 422
    end
  end

  describe "DELETE /settings/users/:id" do
    let(:user) { create :user, company: current_company }

    before { @user = user }

    subject { delete settings_user_path(@user) }

    it { expect { subject }.to change { User.find(@user.id).disabled }.from(false).to(true) }

    context "the user is myself" do
      let(:user) { current_user }

      it do
        subject
        expect(response.status).to eq 422
      end
    end

    context "the user has a slip has the status of NOT COMPLETE" do
      before { @slip = create :slip, company: current_company, user: @user }

      # assertion
      it { expect(@slip.status).not_to eq SLIP_STATUS_COMPLETE }

      it do
        subject
        expect(response.status).to eq 422
      end
    end
  end
end

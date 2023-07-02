require "rails_helper"

RSpec.describe User, type: :model do
  describe ".new_authentication_token" do
    subject { described_class.new_authentication_token }

    it { is_expected.to be_kind_of String }
  end

  describe ".token_digest" do
    let(:token) { "token" }

    subject { described_class.token_digest token }

    it { is_expected.to be_kind_of String }
    it { is_expected.not_to eq "token" }
  end

  describe "#authenticated_locked" do
    let(:user) { create :user }

    subject { user.authenticated_locked }

    it { is_expected.to eq false }

    context do
      let(:user) { create :user, authentication_data: { error_count: USER_AUTHENTICATION_LOCK_COUNT } }

      it { is_expected.to eq true }
    end
  end

  describe "#authenticated_lock_countup" do
    before { @user = create :user, authentication_data: { "error_count": 0 } }

    subject { @user.authenticated_lock_countup }

    it { expect { subject }.to change { @user.authentication_data["error_count"] }.by 1 }
  end

  describe "#authenticated_lock_unlock" do
    before { @user = create :user, authentication_data: { "error_count": USER_AUTHENTICATION_LOCK_COUNT } }

    subject { @user.authenticated_lock_unlock }

    it do
      expect { subject }.to(
        change { @user.authentication_data["error_count"] }.from(USER_AUTHENTICATION_LOCK_COUNT).to(nil)
      )
    end
  end

  describe "Any #data[\"status\"] is valid" do
    before do
      @status = "Doesn\'t exist in company.setting_data[\"user_statuses\"]"
      @user = create :user
      @company = @user.company
    end

    # assertion
    it { expect(@status).not_to be_in @company.setting_data["user_statuses"] }

    describe "validation" do
      before { @user.data["status"] = @status }
      subject { @user.valid? }
      it { is_expected.to eq true }
    end

    describe "save" do
      before { @user.data["status"] = @status }
      subject { @user.save }

      it { is_expected.to eq true }

      it do
        subject
        @user.reload
        expect(@user.data["status"]).to eq @status
      end
    end
  end
end

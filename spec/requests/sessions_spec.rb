require "rails_helper"

RSpec.describe SessionsController, type: :request do
  describe "GET /login" do
    subject { get login_path }

    it "returns 200 OK" do
      subject
      expect(response.status).to eq 200
    end
  end

  describe "POST /login (as user)" do
    let(:user) { create :user }
    let(:company_code) { user.company.company_code }
    let(:identifier) { user.identifier }
    let(:password) { "password" }
    let(:token_2fa) { "" }

    before { post login_path, params: { session: { company_code:, identifier:, password:, token_2fa: } } }

    it { expect(response).to redirect_to chats_url }

    context do
      let(:company_code) { "invalid_company_code" }

      it { expect(response.status).to eq 422 }
    end

    context do
      let(:password) { "" }

      it { expect(response.status).to eq 422 }
    end

    context do
      let(:user) { create :user, authentication_data: { "error_count": USER_AUTHENTICATION_LOCK_COUNT } }

      it { expect(response.status).to eq 422 }
    end
  end
end

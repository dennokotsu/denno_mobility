require "rails_helper"

RSpec.describe ChatsController, type: :request do
  sign_in_user_admin

  describe "GET /chats" do
    before { get chats_path }

    it { expect(response.status).to eq 200 }

    context do
      sign_out_user_admin

      it { expect(response).to redirect_to login_url }
    end
  end

  describe "GET /chats/all" do
    before { get chat_path("all") }

    it { expect(response.status).to eq 200 }
  end

  describe "GET /chats/group" do
    subject { get chat_path("group") }

    it { expect { subject }.to raise_error ActionController::RoutingError }
  end

  describe "GET /chats/:id" do
    before { get chat_path(current_user.id) }

    it { expect(response.status).to eq 200 }
  end
end

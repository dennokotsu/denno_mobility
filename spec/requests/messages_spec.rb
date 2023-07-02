require "rails_helper"

RSpec.describe MessagesController, type: :request do
  sign_in_user

  describe "GET /messages/all" do
    before { get message_path("all") }

    it { expect(response.status).to eq 200 }
  end

  describe "GET /messages/group" do
    subject { get message_path("group") }

    it { expect { subject }.to raise_error ActionController::RoutingError }
  end

  describe "GET /messages/group (with a group)" do
    before do
      @group = create(:group, company: current_company)
      @message = create(:message, company: current_company, from_user_id: current_user.id, group_id: @group.id)
    end

    subject { get message_path("group", group_id: @group.id) }

    it "returns 200 status code" do
      subject
      expect(response.status).to eq 200
    end
  end

  describe "GET /messages/group (with a slip)" do
    before do
      @group = create(:group, company: current_company)
      slip = create :slip, company: current_company
      create(:message, company: current_company, from_user_id: current_user.id, group_id: @group.id,
        data: { "slip_id" => slip.id })
    end

    subject { get message_path("group", group_id: @group.id) }

    it "returns 200 status code" do
      subject
      expect(response.status).to eq 200
    end
  end

  describe "GET /messages/:id" do
    before { @message = create(:message, company: current_company, from_user_id: current_user.id) }

    subject { get message_path(@message) }

    it { expect { subject }.to raise_error ActionController::RoutingError }
  end

  describe "GET /messages/user" do
    before { @user = create(:user, company: current_company) }

    subject { get message_path(@user) }

    it "returns 200 status code" do
      subject
      expect(response.status).to eq 200
    end
  end

  describe "PUT /messages/all" do
    let(:message) { "Message" }

    subject { put message_path("all"), params: { chat_message: { message: } } }

    it do
      subject
      expect(response.status).to eq 204
    end

    it { expect { subject }.to change { Message.count }.by 1 }

    context "message is empty" do
      let(:message) { "" }

      it { expect { subject }.not_to(change { Message.count }) }
    end
  end

  describe "PUT /messages/group" do
    subject { put message_path("group") }

    it { expect { subject }.to raise_error ActionController::RoutingError }
  end

  describe "PUT /messages/other" do
    before { @user = create :user, company: current_company }

    subject { put message_path(@user.id), params: { chat_message: { message: "Message" } } }

    it do
      subject
      expect(response.status).to eq 204
    end
  end

  describe "PUT /messages/all(upload picture)" do
    subject do
      put message_path("all"),
        params: { chat_message: { message: "message", picture: fixture_file_upload("test.gif") } }
    end

    it do
      subject
      expect(response.status).to eq 204
    end
  end
end

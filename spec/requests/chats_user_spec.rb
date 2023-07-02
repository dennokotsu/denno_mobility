require "rails_helper"

RSpec.describe ChatsController, type: :request do
  sign_in_user

  describe "GET /chats" do
    subject { get chats_path }

    it do
      subject
      expect(response.status).to eq 200
    end

    context "user isn't signing in" do
      sign_out_user

      it do
        subject
        expect(response).to redirect_to login_url
      end
    end

    context "with last_all_message" do
      let(:message_creation_time) { Time.zone.now }

      before do
        travel_to message_creation_time
        create(:message, company: current_company)
        travel_back
      end

      it do
        subject
        expect(response.status).to eq 200
      end

      context "last_all_message was created \"yesterday\"" do
        let(:message_creation_time) { Time.zone.now.yesterday }

        it do
          subject
          expect(response.status).to eq 200
        end
      end
    end

    context "with group_user" do
      before do
        group = create(:group, company: current_company)
        create(:group_user, company: current_company, user: current_user, group:)
      end

      it do
        subject
        expect(response.status).to eq 200
      end
    end

    context "get_setting(\"chat_type\") != \"all\"" do
      before do
        setting_data = current_company.setting_data.dup
        setting_data["chat_type"] = "limit"
        current_company.update(setting_data:)
      end

      # assertion
      # NOTE: get_setting("chat_type") == current_company.setting_data["chat_type"]
      it { expect(current_company.setting_data["chat_type"]).not_to eq "all" }

      it do
        subject
        expect(response.status).to eq 200
      end
    end

    context "with last_message" do
      let(:message_creation_time) { Time.zone.now }

      before do
        travel_to message_creation_time
        user = create(:user, company: current_company)
        create(:message, company: current_company, from_user_id: current_user.id, to_user_id: user.id)
        travel_back
      end

      it do
        subject
        expect(response.status).to eq 200
      end

      context "last_user_message was created \"yesterday\"" do
        let(:message_creation_time) { Time.zone.now.yesterday }

        it do
          subject
          expect(response.status).to eq 200
        end
      end
    end

    context "with last_group_message" do
      let(:message_creation_time) { Time.zone.now }

      before do
        travel_to message_creation_time
        group = create(:group, company: current_company)
        create(:group_user, company: current_company, user: current_user, group:)
        create(:message, company: current_company, group_id: group.id)
        travel_back
      end

      it do
        subject
        expect(response.status).to eq 200
      end

      context "last_group_message was created \"yesterday\"" do
        let(:message_creation_time) { Time.zone.now.yesterday }

        it do
          subject
          expect(response.status).to eq 200
        end
      end
    end

    describe "calc_distance & calc_angle methods do their main processes" do
      before do
        current_user.update(position: "POINT( 34.07081426109131 134.55488498956288 )")
        create(:user, company: current_company, position: "POINT( 34.07081426109131 134.55488498956288 )")
      end

      it do
        expect(Common::Geo).to receive(:calc_distance).and_return(0.0)
        expect(Common::Geo).to receive(:calc_angle).and_return(0.0)
        subject
      end
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

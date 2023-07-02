require "rails_helper"

RSpec.describe SidebarController, type: :request do
  sign_in_user

  describe "GET /sidebar (without status parameter)" do
    subject { get sidebar_index_path }

    it do
      subject
      expect(response.status).to eq 200
    end

    it do
      expect_any_instance_of(User).not_to receive(:save)
      expect_any_instance_of(User).not_to receive(:save!)
      expect_any_instance_of(User).not_to receive(:update)
      expect_any_instance_of(User).not_to receive(:update!)
      subject
    end
  end

  describe "GET /sidebar?status=foo" do
    before { current_user.update! data: { status: "Before" } }

    subject { get sidebar_index_path(status: "After") }

    it { expect { subject }.to change { User.find(current_user.id).data["status"] }.from("Before").to("After") }
  end
end

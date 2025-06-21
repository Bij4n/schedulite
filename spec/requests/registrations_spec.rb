require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET /register" do
    it "renders the signup page" do
      get register_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Start your free trial")
    end
  end

  describe "POST /register" do
    let(:valid_params) do
      {
        registration: {
          practice_name: "Sunrise Dental",
          subdomain: "sunrise-dental",
          first_name: "Jane",
          last_name: "Smith",
          email: "jane@sunrisedental.com",
          password: "securepass123!"
        }
      }
    end

    it "creates a tenant and owner user" do
      expect {
        post register_path, params: valid_params
      }.to change(Tenant, :count).by(1).and change(User, :count).by(1)
    end

    it "sets the user as owner" do
      post register_path, params: valid_params
      expect(User.last.role).to eq("owner")
    end

    it "sets a 14-day trial" do
      post register_path, params: valid_params
      expect(Tenant.last.trial_ends_at).to be_within(1.day).of(14.days.from_now)
    end

    it "redirects to dashboard after signup" do
      post register_path, params: valid_params
      expect(response).to redirect_to(root_path)
    end

    it "rejects duplicate subdomains" do
      create(:tenant, subdomain: "sunrise-dental")
      post register_path, params: valid_params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

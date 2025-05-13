require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }

  describe "GET / (dashboard)" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns success" do
        get root_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /users/sign_in" do
    it "signs in with valid credentials" do
      post user_session_path, params: {
        user: { email: user.email, password: user.password }
      }
      expect(response).to redirect_to(root_path)
    end

    it "rejects invalid credentials" do
      post user_session_path, params: {
        user: { email: user.email, password: "wrongpassword" }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /users/sign_out" do
    before { sign_in user }

    it "signs the user out" do
      delete destroy_user_session_path
      get root_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end

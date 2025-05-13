require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tenant) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end

  describe "roles" do
    it { is_expected.to define_enum_for(:role).with_values(owner: 0, admin: 1, front_desk: 2, provider: 3) }

    it "defaults to front_desk" do
      user = User.new
      expect(user.role).to eq("front_desk")
    end
  end

  describe "devise modules" do
    it "includes database_authenticatable" do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it "includes timeoutable" do
      expect(User.devise_modules).to include(:timeoutable)
    end

    it "includes recoverable" do
      expect(User.devise_modules).to include(:recoverable)
    end

    it "includes validatable" do
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe "#full_name" do
    it "returns first and last name" do
      user = build(:user, first_name: "Jane", last_name: "Doe")
      expect(user.full_name).to eq("Jane Doe")
    end
  end
end

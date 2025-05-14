require "rails_helper"

RSpec.describe GiftCard, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:appointment) }
    it { is_expected.to belong_to(:tenant) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:amount_cents) }
    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than(0) }
  end
end

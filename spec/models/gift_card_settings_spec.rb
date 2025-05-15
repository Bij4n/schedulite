require "rails_helper"

RSpec.describe GiftCardSettings, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tenant) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:delay_threshold_minutes) }
    it { is_expected.to validate_numericality_of(:delay_threshold_minutes).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:amount_cents) }
    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than(0) }
  end
end

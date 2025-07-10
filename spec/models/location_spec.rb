require "rails_helper"

RSpec.describe Location, type: :model do
  let(:tenant) { create(:tenant) }

  describe "validations" do
    it "requires a name" do
      location = Location.new(tenant: tenant)
      expect(location).not_to be_valid
      expect(location.errors[:name]).to be_present
    end

    it "is valid with a name and tenant" do
      location = Location.new(tenant: tenant, name: "Downtown Office")
      expect(location).to be_valid
    end
  end

  describe "associations" do
    it "has many providers" do
      location = create(:location, tenant: tenant)
      provider = create(:provider, tenant: tenant, location: location)
      expect(location.providers).to include(provider)
    end

    it "has many appointments" do
      location = create(:location, tenant: tenant)
      provider = create(:provider, tenant: tenant)
      patient = create(:patient, tenant: tenant)
      appointment = create(:appointment, tenant: tenant, provider: provider, patient: patient,
        location: location, starts_at: 1.hour.from_now)
      expect(location.appointments).to include(appointment)
    end
  end

  describe "#full_address" do
    it "joins address fields" do
      location = create(:location, tenant: tenant, address: "1 Market St", city: "SF", state: "CA", zip: "94105")
      expect(location.full_address).to eq("1 Market St, SF, CA, 94105")
    end
  end
end

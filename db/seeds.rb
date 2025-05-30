return if Tenant.any?

tenant = Tenant.create!(name: "Sunrise Family Medicine", subdomain: "sunrise", baa_uploaded_at: Time.current)

staff = User.create!(
  tenant: tenant,
  first_name: "Maria",
  last_name: "Santos",
  email: "maria@sunrise.example.com",
  password: "password123!",
  role: :owner
)

dr_lee = Provider.create!(tenant: tenant, first_name: "Sarah", last_name: "Lee")
dr_chen = Provider.create!(tenant: tenant, first_name: "Michael", last_name: "Chen")
np_patel = Provider.create!(tenant: tenant, first_name: "Priya", last_name: "Patel", title: "NP")

patients = [
  { first_name: "Alex", last_name: "Rivera", phone: "5551000001", date_of_birth: "1985-06-15" },
  { first_name: "Jordan", last_name: "Kim", phone: "5551000002", date_of_birth: "1992-03-22" },
  { first_name: "Sam", last_name: "Okafor", phone: "5551000003", date_of_birth: "1978-11-08" },
  { first_name: "Taylor", last_name: "Nguyen", phone: "5551000004", date_of_birth: "2001-01-30" },
  { first_name: "Morgan", last_name: "Davis", phone: "5551000005", date_of_birth: "1965-09-12" },
  { first_name: "Casey", last_name: "Brooks", phone: "5551000006", date_of_birth: "1990-07-04" },
  { first_name: "Riley", last_name: "Martinez", phone: "5551000007", date_of_birth: "1988-12-25" },
  { first_name: "Jamie", last_name: "Thompson", phone: "5551000008", date_of_birth: "1973-04-18" }
].map { |attrs| Patient.create!(tenant: tenant, sms_consent: true, primary_provider: dr_lee, **attrs) }

today = Date.current

appointments_data = [
  { patient: patients[0], provider: dr_lee,  hour: 9,  min: 0,  status: :complete },
  { patient: patients[1], provider: dr_lee,  hour: 9,  min: 30, status: :complete },
  { patient: patients[2], provider: dr_chen, hour: 10, min: 0,  status: :in_room },
  { patient: patients[3], provider: dr_lee,  hour: 10, min: 30, status: :checked_in },
  { patient: patients[4], provider: np_patel, hour: 11, min: 0,  status: :running_late },
  { patient: patients[5], provider: dr_chen, hour: 13, min: 30, status: :scheduled },
  { patient: patients[6], provider: dr_lee,  hour: 14, min: 0,  status: :scheduled },
  { patient: patients[7], provider: np_patel, hour: 15, min: 30, status: :scheduled }
]

appointments_data.each do |data|
  Appointment.create!(
    tenant: tenant,
    patient: data[:patient],
    provider: data[:provider],
    starts_at: today.in_time_zone.change(hour: data[:hour], min: data[:min]),
    status: data[:status]
  )
end

puts "Seeded: 1 tenant, 1 staff, 3 providers, 8 patients, 8 appointments"
puts "Sign in: maria@sunrise.example.com / password123!"

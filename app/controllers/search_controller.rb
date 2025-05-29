class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    query = params[:q].to_s.strip
    return render json: { results: [] } if query.length < 2

    patients = search_patients(query)
    appointments = search_appointments(query)

    render json: {
      results: patients.map { |p| patient_result(p) } + appointments.map { |a| appointment_result(a) }
    }
  end

  private

  def search_patients(query)
    # Search by phone via blind index
    phone_digits = query.gsub(/\D/, "")
    if phone_digits.length >= 4
      Patient.where(phone: phone_digits).limit(5)
    else
      # Can't search encrypted name fields via SQL, so load and filter in Ruby
      # This is acceptable for small-medium practice sizes (<5000 patients)
      Patient.all.select { |p|
        "#{p.first_name} #{p.last_name}".downcase.include?(query.downcase)
      }.first(5)
    end
  end

  def search_appointments(query)
    # Search upcoming appointments by patient name (in Ruby due to encryption)
    Appointment.where("starts_at >= ?", Date.current.beginning_of_day)
               .includes(:patient, :provider)
               .order(:starts_at)
               .limit(50)
               .select { |a|
                 a.patient.display_name.downcase.include?(query.downcase) ||
                 a.provider.display_name.downcase.include?(query.downcase)
               }.first(5)
  end

  def patient_result(patient)
    {
      type: "patient",
      label: "#{patient.first_name} #{patient.last_name}",
      sublabel: format_phone(patient.phone),
      url: patient_path(patient)
    }
  end

  def appointment_result(appointment)
    {
      type: "appointment",
      label: "#{appointment.patient.display_name} — #{appointment.starts_at.strftime('%-l:%M %p')}",
      sublabel: "#{appointment.starts_at.strftime('%b %-d')} · #{appointment.provider.display_name}",
      url: appointment_path(appointment)
    }
  end

  def format_phone(phone)
    helpers.format_phone(phone)
  end
end

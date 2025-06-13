class AppointmentPolicy < ApplicationPolicy
  def check_in?
    true # All roles can check in patients
  end

  def update_status?
    true # All roles can update status
  end

  def show?
    if user.provider?
      # Providers can only see their own appointments
      record.provider_id == associated_provider_id
    else
      true
    end
  end

  def destroy?
    user.owner?
  end

  def export?
    user.owner? || user.manager?
  end

  def reschedule?
    user.owner? || user.manager? || user.staff?
  end

  def cancel?
    user.owner? || user.manager? || user.staff?
  end

  def no_show?
    user.owner? || user.manager?
  end

  private

  def associated_provider_id
    Provider.find_by(
      first_name: user.first_name,
      last_name: user.last_name,
      tenant: user.tenant
    )&.id
  end
end

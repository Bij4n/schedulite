class AppointmentPolicy < ApplicationPolicy
  def check_in?
    true
  end

  def update_status?
    true
  end

  def show?
    true
  end

  def destroy?
    owner_or_admin?
  end

  def export?
    !user.front_desk?
  end
end

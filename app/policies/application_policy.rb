class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def owner_or_manager?
    user.owner? || user.manager?
  end
end

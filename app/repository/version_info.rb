class VersionInfo
  attr_reader :model
  def initialize(model)
    @model = model
  end

  def user_name_with_email
    return "Unknown" if unknown?
    User.find(model.last_updated_by).full_name_with_email
  end

  def last_updated_on
    return "Unknown" if unknown?
    I18n.l(model.last_updated_on.to_date, format: :gee_fu)
  end

  def unknown?
    !User.exists?(model.last_updated_by)
  end
end
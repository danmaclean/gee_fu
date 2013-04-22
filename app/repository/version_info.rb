class VersionInfo
  attr_reader :model
  def initialize(model)
    @model = model
  end

  def user_name
    return "Unknown" unless User.exists?(model.last_updated_by)
    User.find(model.last_updated_by).full_name
  end

  def last_updated_on
    return "Unknown" unless model.last_updated_on.present?
    I18n.l(model.last_updated_on.to_date, format: :gee_fu)
  end
end
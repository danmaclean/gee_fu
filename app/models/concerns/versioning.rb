module Concerns
  module Versioning
    def last_updated_by
      return nil unless versions.last.present?
      versions.last.whodunnit.to_i
    end

    def last_updated_on
      return nil unless versions.last.present?
      versions.last.created_at
    end
  end
end
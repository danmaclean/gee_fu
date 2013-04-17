class FeaturePresenter
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers

  def initialize(feature)
    @feature = feature
  end

  def parent_list
    return 'none' unless @feature.has_parent?
    @feature.parents.map { |parent|
      grand_parent = parent.parent_obj
      _link_to grand_parent.id, edit_feature_path(grand_parent.id)
    }.join(",").html_safe
  end

  def attributes
    JSON.parse(@feature.group).join(" ")
  end

  private

  def _link_to(name, url, options={})
    href = { :href => url }
    content_tag(:a, name, options.merge(href))
  end
end


# frozen_string_literal: true

module ActiveAdmin::SmartLinkHelper
  def smart_url_for(object, params = nil)
    url = auto_url_for(object)
    return if url.blank?

    url << "?#{params.try(:to_param)}" unless params.nil?
    url
  end
end

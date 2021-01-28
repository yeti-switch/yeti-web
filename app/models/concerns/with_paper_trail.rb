# frozen_string_literal: true

module WithPaperTrail
  extend ActiveSupport::Concern

  included do
    has_paper_trail class_name: 'AuditLogItem', if: proc { Rails.configuration.yeti_web['versioning_disable_for_models'].exclude?(name) }
  end
end

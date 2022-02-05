# frozen_string_literal: true

module WithPaperTrail
  extend ActiveSupport::Concern

  included do
    has_paper_trail versions: { class_name: 'AuditLogItem' },
                    if: proc { YetiConfig.versioning_disable_for_models.exclude?(name) }
  end
end

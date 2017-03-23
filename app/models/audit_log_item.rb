class AuditLogItem < PaperTrail::Version
    scope :destroyed, -> { where event: 'destroy' }
    scope :updated,   -> { where event: 'update'  }
    scope :created,   -> { where event: 'create'  }
end

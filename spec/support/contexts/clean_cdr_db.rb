# frozen_string_literal: true

# Cdr::Base models use a separate database connection (connects_to :cdr).
# use_transactional_fixtures does not reliably clean this database between tests.
# Include this context in any spec that creates Cdr::Cdr or Cdr::AuthLog records.
shared_context :clean_cdr_db do
  before do
    Cdr::Cdr.delete_all
    Cdr::AuthLog.delete_all
  end
end

# frozen_string_literal: true

module CustomRspecHelper
  def safe_subject
    subject
  rescue StandardError
    nil
  end
end

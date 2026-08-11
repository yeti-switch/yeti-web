# frozen_string_literal: true

# Plain-text alternative part of an outgoing email. Nullable: only senders that
# supply one produce a multipart message, so existing senders (balance
# notifications, report emails) keep sending single-part HTML unchanged.
class AddTextMsgToEmailLogs < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE notifications.email_logs ADD COLUMN text_msg text;
    }
  end

  def down
    execute %q{
      ALTER TABLE notifications.email_logs DROP COLUMN text_msg;
    }
  end
end

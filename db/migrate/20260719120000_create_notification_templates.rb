# frozen_string_literal: true

class CreateNotificationTemplates < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      CREATE TABLE billing.notification_templates (
        id serial PRIMARY KEY,
        event character varying NOT NULL,
        subject character varying NOT NULL,
        body text NOT NULL
      );
      CREATE UNIQUE INDEX notification_templates_event_key ON billing.notification_templates USING btree (event);
    }

    # Seed the templates. A row must exist for every balance event: it is the only
    # source of the email, there is no packaged fallback. The admin UI can edit
    # them but never create or destroy. Fresh installs load db/structure.sql
    # (schema only, no data) and get these from db/seeds/main/billing.sql instead.
    execute <<~'SQL'
      INSERT INTO billing.notification_templates (id, event, subject, body) VALUES (1, $tpl$AccountLowThesholdReached$tpl$, $tpl$Low balance warning: {{ account.name }} ({{ account.balance }} {{ account.currency }})$tpl$, $tpl$
      <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f5f5;padding:24px 0;font-family:Arial,Helvetica,sans-serif;">
        <tr>
          <td align="center">
            <table width="600" cellpadding="0" cellspacing="0" border="0" style="width:600px;max-width:600px;background-color:#ffffff;border:1px solid #e8e8e8;">
              <tr>
                <td style="background-color:#c0392b;padding:16px 24px;color:#ffffff;font-size:18px;font-weight:bold;">Low balance warning</td>
              </tr>
              <tr>
                <td style="padding:24px;color:#333333;font-size:14px;line-height:20px;">
                  <p style="margin:0 0 16px 0;">The balance of account <strong>{{ account.name }}</strong> has dropped below the configured low threshold.</p>
                  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border:1px solid #e8e8e8;border-collapse:collapse;">
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;width:45%;">Current balance</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;font-weight:bold;">{{ account.balance }} {{ account.currency }}</td>
                    </tr>
                    {% if threshold.low %}<tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Low threshold</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ threshold.low }} {{ account.currency }}</td>
                    </tr>{% endif %}
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Account</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ account.name }} (ID {{ account.id }})</td>
                    </tr>
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Time</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ event.time }}</td>
                    </tr>
                  </table>
                  <p style="margin:16px 0 0 0;">Please top up the account to avoid interruption of service.</p>
                </td>
              </tr>
              <tr>
                <td style="padding:16px 24px;border-top:1px solid #e8e8e8;color:#888888;font-size:12px;">This is an automated notification. Please do not reply to this message.</td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
      $tpl$);

      INSERT INTO billing.notification_templates (id, event, subject, body) VALUES (2, $tpl$AccountHighThesholdReached$tpl$, $tpl$High balance notice: {{ account.name }} ({{ account.balance }} {{ account.currency }})$tpl$, $tpl$
      <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f5f5;padding:24px 0;font-family:Arial,Helvetica,sans-serif;">
        <tr>
          <td align="center">
            <table width="600" cellpadding="0" cellspacing="0" border="0" style="width:600px;max-width:600px;background-color:#ffffff;border:1px solid #e8e8e8;">
              <tr>
                <td style="background-color:#d68910;padding:16px 24px;color:#ffffff;font-size:18px;font-weight:bold;">High balance notice</td>
              </tr>
              <tr>
                <td style="padding:24px;color:#333333;font-size:14px;line-height:20px;">
                  <p style="margin:0 0 16px 0;">The balance of account <strong>{{ account.name }}</strong> has risen above the configured high threshold.</p>
                  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border:1px solid #e8e8e8;border-collapse:collapse;">
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;width:45%;">Current balance</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;font-weight:bold;">{{ account.balance }} {{ account.currency }}</td>
                    </tr>
                    {% if threshold.high %}<tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">High threshold</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ threshold.high }} {{ account.currency }}</td>
                    </tr>{% endif %}
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Account</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ account.name }} (ID {{ account.id }})</td>
                    </tr>
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Time</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ event.time }}</td>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td style="padding:16px 24px;border-top:1px solid #e8e8e8;color:#888888;font-size:12px;">This is an automated notification. Please do not reply to this message.</td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
      $tpl$);

      INSERT INTO billing.notification_templates (id, event, subject, body) VALUES (3, $tpl$AccountLowThesholdCleared$tpl$, $tpl$Balance restored: {{ account.name }} ({{ account.balance }} {{ account.currency }})$tpl$, $tpl$
      <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f5f5;padding:24px 0;font-family:Arial,Helvetica,sans-serif;">
        <tr>
          <td align="center">
            <table width="600" cellpadding="0" cellspacing="0" border="0" style="width:600px;max-width:600px;background-color:#ffffff;border:1px solid #e8e8e8;">
              <tr>
                <td style="background-color:#1e8449;padding:16px 24px;color:#ffffff;font-size:18px;font-weight:bold;">Balance restored</td>
              </tr>
              <tr>
                <td style="padding:24px;color:#333333;font-size:14px;line-height:20px;">
                  <p style="margin:0 0 16px 0;">The balance of account <strong>{{ account.name }}</strong> is back above the configured low threshold. No further action is required.</p>
                  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border:1px solid #e8e8e8;border-collapse:collapse;">
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;width:45%;">Current balance</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;font-weight:bold;">{{ account.balance }} {{ account.currency }}</td>
                    </tr>
                    {% if threshold.low %}<tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Low threshold</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ threshold.low }} {{ account.currency }}</td>
                    </tr>{% endif %}
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Account</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ account.name }} (ID {{ account.id }})</td>
                    </tr>
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Time</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ event.time }}</td>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td style="padding:16px 24px;border-top:1px solid #e8e8e8;color:#888888;font-size:12px;">This is an automated notification. Please do not reply to this message.</td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
      $tpl$);

      INSERT INTO billing.notification_templates (id, event, subject, body) VALUES (4, $tpl$AccountHighThesholdCleared$tpl$, $tpl$Balance back to normal: {{ account.name }} ({{ account.balance }} {{ account.currency }})$tpl$, $tpl$
      <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f5f5;padding:24px 0;font-family:Arial,Helvetica,sans-serif;">
        <tr>
          <td align="center">
            <table width="600" cellpadding="0" cellspacing="0" border="0" style="width:600px;max-width:600px;background-color:#ffffff;border:1px solid #e8e8e8;">
              <tr>
                <td style="background-color:#1e8449;padding:16px 24px;color:#ffffff;font-size:18px;font-weight:bold;">Balance back to normal</td>
              </tr>
              <tr>
                <td style="padding:24px;color:#333333;font-size:14px;line-height:20px;">
                  <p style="margin:0 0 16px 0;">The balance of account <strong>{{ account.name }}</strong> is back below the configured high threshold. No further action is required.</p>
                  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border:1px solid #e8e8e8;border-collapse:collapse;">
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;width:45%;">Current balance</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;font-weight:bold;">{{ account.balance }} {{ account.currency }}</td>
                    </tr>
                    {% if threshold.high %}<tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">High threshold</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ threshold.high }} {{ account.currency }}</td>
                    </tr>{% endif %}
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Account</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ account.name }} (ID {{ account.id }})</td>
                    </tr>
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Time</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ event.time }}</td>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td style="padding:16px 24px;border-top:1px solid #e8e8e8;color:#888888;font-size:12px;">This is an automated notification. Please do not reply to this message.</td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
      $tpl$);

      SELECT pg_catalog.setval('billing.notification_templates_id_seq', 4, true);
    SQL
  end

  def down
    execute %q{
      DROP TABLE billing.notification_templates;
    }
  end
end

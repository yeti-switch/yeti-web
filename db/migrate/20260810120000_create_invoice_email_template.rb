# frozen_string_literal: true

# The invoice notification email, as an editable liquid template. One row,
# system-wide: the CHECK makes the singleton a database fact rather than a
# convention, so there is no id to choose and nothing to select per account.
#
# Both bodies are NOT NULL and seeded here, because there is no packaged
# fallback — a blank row would mean invoices go out with an empty message.
class CreateInvoiceEmailTemplate < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      CREATE TABLE billing.invoice_email_templates (
        id smallint PRIMARY KEY DEFAULT 1,
        subject character varying NOT NULL,
        html_body text NOT NULL,
        text_body text NOT NULL,
        CONSTRAINT invoice_email_templates_singleton CHECK (id = 1)
      );
    }

    execute <<~'SQL'
      INSERT INTO billing.invoice_email_templates (id, subject, html_body, text_body) VALUES (1, $tpl$Invoice {{ invoice.reference }}$tpl$, $tpl$
      <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f4f5f5;padding:24px 0;font-family:Arial,Helvetica,sans-serif;">
        <tr>
          <td align="center">
            <table width="600" cellpadding="0" cellspacing="0" border="0" style="width:600px;max-width:600px;background-color:#ffffff;border:1px solid #e8e8e8;">
              <tr>
                <td style="background-color:#2c3e50;padding:16px 24px;color:#ffffff;font-size:18px;font-weight:bold;">Invoice {{ invoice.reference }}</td>
              </tr>
              <tr>
                <td style="padding:24px;color:#333333;font-size:14px;line-height:20px;">
                  <p style="margin:0 0 16px 0;">Dear {{ account.name }},</p>
                  <p style="margin:0 0 16px 0;">Please find attached invoice <strong>{{ invoice.reference }}</strong> covering the period from {{ invoice.start_date | date: "%Y-%m-%d" }} to {{ invoice.end_date | date: "%Y-%m-%d" }}.</p>
                  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border:1px solid #e8e8e8;border-collapse:collapse;">
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;width:45%;">Invoice reference</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;font-weight:bold;">{{ invoice.reference }}</td>
                    </tr>
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Period</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ invoice.start_date | date: "%Y-%m-%d" }} &ndash; {{ invoice.end_date | date: "%Y-%m-%d" }}</td>
                    </tr>
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Account</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ account.name }} (ID {{ account.id }})</td>
                    </tr>
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Amount</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;font-weight:bold;">{{ invoice.amount_total }} {{ account.currency }}</td>
                    </tr>
                    <tr>
                      <td style="border:1px solid #e8e8e8;padding:8px;background-color:#f4f5f5;">Attachment</td>
                      <td style="border:1px solid #e8e8e8;padding:8px;">{{ document.filename }}</td>
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
      $tpl$, $tpl$Invoice {{ invoice.reference }}

      Dear {{ account.name }},

      Please find attached invoice {{ invoice.reference }} covering the period
      from {{ invoice.start_date | date: "%Y-%m-%d" }} to {{ invoice.end_date | date: "%Y-%m-%d" }}.

        Invoice reference: {{ invoice.reference }}
        Period:            {{ invoice.start_date | date: "%Y-%m-%d" }} - {{ invoice.end_date | date: "%Y-%m-%d" }}
        Account:           {{ account.name }} (ID {{ account.id }})
        Amount:            {{ invoice.amount_total }} {{ account.currency }}
        Attachment:        {{ document.filename }}

      This is an automated notification. Please do not reply to this message.
      $tpl$);
    SQL
  end

  def down
    execute %q{
      DROP TABLE billing.invoice_email_templates;
    }
  end
end

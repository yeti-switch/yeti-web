# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.invoice_email_templates
# Database name: primary
#
#  id        :integer(2)       default(1), not null, primary key
#  html_body :text             not null
#  subject   :string           not null
#  text_body :text             not null
#
RSpec.describe Billing::InvoiceEmailTemplate do
  let(:template) { described_class.instance }
  let(:assigns) { InvoiceMail.sample_assigns }

  describe '.instance' do
    it 'returns the seeded row' do
      expect(template).to be_present
      expect(template.id).to eq(1)
    end
  end

  describe 'the singleton constraint' do
    it 'refuses a second row' do
      expect { described_class.connection.execute(<<~SQL) }.to raise_error(ActiveRecord::StatementInvalid)
        INSERT INTO billing.invoice_email_templates (id, subject, html_body, text_body)
        VALUES (2, 's', 'h', 't')
      SQL
    end
  end

  describe '#destroy' do
    it 'is refused, because there is no packaged fallback for the bodies' do
      expect(template.destroy).to be false
      expect(described_class.exists?(template.id)).to be true
    end
  end

  describe 'validation' do
    it 'rejects invalid liquid syntax' do
      template.html_body = '{% if %}broken'
      expect(template).not_to be_valid
      expect(template.errors[:html_body].first).to match(/liquid syntax error/)
    end

    it 'rejects references to variables that will never be supplied' do
      template.text_body = '{{ invoice.secret_column }}'
      expect(template).not_to be_valid
      expect(template.errors[:text_body].first).to match(/unknown variable/)
    end

    it 'validates the subject too' do
      template.subject = '{{ invoice.nope }}'
      expect(template).not_to be_valid
      expect(template.errors[:subject].first).to match(/unknown variable/)
    end

    it 'accepts a template using only the documented contract' do
      template.subject = 'Invoice {{ invoice.reference }}'
      template.html_body = '<p>{{ account.name }} owes {{ invoice.amount_total }} {{ account.currency }}</p>'
      template.text_body = '{{ document.filename }}'
      expect(template).to be_valid
    end

    it 'requires both bodies, since every invoice email carries both parts' do
      template.html_body = ''
      template.text_body = ''
      expect(template).not_to be_valid
      expect(template.errors[:html_body]).to be_present
      expect(template.errors[:text_body]).to be_present
    end
  end

  describe 'seeded content' do
    it 'ships usable templates, since there is no packaged fallback' do
      expect(template.subject).to be_present
      expect(template.html_body).to be_present
      expect(template.text_body).to be_present
      expect(template).to be_valid
    end
  end

  describe '#render_subject' do
    it 'renders the stored template' do
      template.update!(subject: 'Invoice {{ invoice.reference }}')
      expect(template.render_subject(assigns)).to eq('Invoice invoice-1042')
    end

    it 'strips surrounding whitespace, because EmailLog#subject is NOT NULL' do
      template.update!(subject: "  {{ invoice.reference }}\n")
      expect(template.render_subject(assigns)).to eq('invoice-1042')
    end
  end

  describe '#render_text_body' do
    it 'renders the stored template' do
      template.update!(text_body: 'Total {{ invoice.amount_total }}')
      expect(template.render_text_body(assigns)).to eq('Total 1234.56')
    end

    context 'when a row bypasses validation with an unknown variable' do
      before { template.update_column(:text_body, 'X {{ invoice.nope }} Y') }

      it 'degrades to a blank instead of raising, so the delivery is not lost' do
        expect { @rendered = template.render_text_body(assigns) }.not_to raise_error
        expect(@rendered).to eq('X  Y')
      end

      it 'logs the undefined variable rather than failing silently' do
        expect(Rails.logger).to receive(:warn)
        template.render_text_body(assigns)
      end
    end
  end

  describe '#render_html_body' do
    it 'renders the stored template' do
      template.update!(html_body: '<b>{{ account.name }}</b>')
      expect(template.render_html_body(assigns)).to eq('<b>Sample account</b>')
    end
  end
end

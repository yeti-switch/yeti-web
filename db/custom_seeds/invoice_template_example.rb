# frozen_string_literal: true

# On-demand example HTML invoice template (rendered to PDF by the yeti-pdf
# service). Not part of the default seeds so it never pollutes test/fresh
# installs; load it explicitly with:
#
#   rake custom_seeds[invoice_template_example]
#
# Created once; an existing row with the same name is left untouched.
Billing::InvoiceTemplate.find_or_create_by!(name: 'Example (HTML)') do |template|
  template.html_template = File.read(Rails.root.join('db/custom_seeds/invoice_template_example.html'))
end

# frozen_string_literal: true

module Billing
  class InvoicePolicy < ::RolePolicy
    section 'Billing/Invoice'

    alias_rule :approve?, :regenerate_document?, to: :perform?
    # PDF access follows read: anyone who can view the invoice can view its PDF
    # (show-page tab, pdf?) and download it (export_file_pdf?) — it is the same
    # data the show page already exposes.
    alias_rule :pdf?, :export_file_pdf?, to: :read?

    # Only pending invoices are editable (and only their reference — enforced by
    # the admin form + permit_params). This hides the Edit link for non-pending
    # invoices and blocks the update action.
    def update?
      record.state.pending? && super
    end

    def edit?
      update?
    end

    class Scope < ::RolePolicy::Scope
    end
  end
end

# == Schema Information
#
# Table name: data_import.import_accounts
#
#  id                             :integer          not null, primary key
#  o_id                           :integer
#  contractor_name                :string
#  contractor_id                  :integer
#  balance                        :decimal(, )
#  min_balance                    :decimal(, )
#  max_balance                    :decimal(, )
#  name                           :string
#  origination_capacity           :integer
#  termination_capacity           :integer
#  error_string                   :string
#  invoice_period_id              :integer
#  invoice_period_name            :string
#  autogenerate_vendor_invoices   :boolean          default(FALSE), not null
#  autogenerate_customer_invoices :boolean          default(FALSE), not null
#

class Importing::Account  < Importing::Base
    self.table_name = 'data_import.import_accounts'
    attr_accessor :file
    belongs_to :contractor, class_name: '::Contractor'
    
    self.import_attributes = ['contractor_id','name', 'balance',
                  'min_balance', 'max_balance','origination_capacity','termination_capacity']

    self.import_class = ::Account

end

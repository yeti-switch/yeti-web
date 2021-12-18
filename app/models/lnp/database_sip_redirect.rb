# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.lnp_databases_30x_redirect
#
#  id        :integer(2)       not null, primary key
#  host      :string           not null
#  port      :integer(4)
#  timeout   :integer(2)       default(300), not null
#  format_id :integer(2)       default(1), not null
#
# Foreign Keys
#
#  lnp_databases_30x_redirect_format_id_fkey  (format_id => lnp_databases_30x_redirect_formats.id)
#

class Lnp::DatabaseSipRedirect < ApplicationRecord
  self.table_name = 'class4.lnp_databases_30x_redirect'

  has_one :lnp_database, as: :database, class_name: 'Lnp::Database'
  belongs_to :format, class_name: 'Lnp::DatabaseSipRedirectFormat', foreign_key: :format_id

  validates :host, presence: true
  validates :timeout, allow_nil: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: PG_MAX_SMALLINT,
    only_integer: true
  }
  validates :format_id, presence: true

end

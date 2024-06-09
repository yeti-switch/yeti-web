# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.service_types
#
#  id                 :integer(2)       not null, primary key
#  force_renew        :boolean          default(FALSE), not null
#  name               :string           not null
#  provisioning_class :string
#  variables          :jsonb
#
# Indexes
#
#  service_types_name_key  (name) UNIQUE
#
RSpec.describe Billing::ServiceType do
  describe 'validations' do
    it { is_expected.to allow_value('Billing::Provisioning::Logging').for(:provisioning_class) }
    it { is_expected.not_to allow_value('').for(:provisioning_class) }
    it { is_expected.not_to allow_value(nil).for(:provisioning_class) }
    it { is_expected.not_to allow_value('Billing::Provisioning::Base').for(:provisioning_class) }
    it { is_expected.not_to allow_value('Billing::Service').for(:provisioning_class) }
    it { is_expected.not_to allow_value('NotExistingConst').for(:provisioning_class) }
    it { is_expected.to allow_value(nil, { foo: 'bar' }).for(:variables) }
    it { is_expected.not_to allow_value('').for(:variables) }
    it { is_expected.not_to allow_value('test').for(:variables) }
    it { is_expected.not_to allow_value([{ foo: 'bar' }]).for(:variables) }
    it { is_expected.not_to allow_value(123).for(:variables) }
    it { is_expected.not_to allow_value(true).for(:variables) }
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.services
#
#  id              :bigint(8)        not null, primary key
#  initial_price   :decimal(, )      not null
#  name            :string
#  renew_at        :timestamptz
#  renew_price     :decimal(, )      not null
#  uuid            :uuid             not null
#  variables       :jsonb
#  created_at      :timestamptz      not null
#  account_id      :integer(4)       not null
#  renew_period_id :integer(2)
#  state_id        :integer(2)       default(10), not null
#  type_id         :integer(2)       not null
#
# Indexes
#
#  services_account_id_idx  (account_id)
#  services_renew_at_idx    (renew_at)
#  services_type_id_idx     (type_id)
#  services_uuid_idx        (uuid)
#
# Foreign Keys
#
#  services_account_id_fkey  (account_id => accounts.id)
#  services_type_id_fkey     (type_id => service_types.id)
#
RSpec.describe Billing::Service do
  describe '.create' do
    subject do
      described_class.create(create_params)
    end

    let!(:account) { create(:account) }
    let!(:service_type) { create(:service_type, service_type_attrs) }
    let(:service_type_attrs) do
      { provisioning_class: 'Billing::Provisioning::Logging' }
    end
    let(:create_params) do
      {
        name: 'test',
        account:,
        type: service_type,
        initial_price: 10,
        renew_price: 20
      }
    end
    let(:default_attributes) do
      {
        renew_at: nil,
        renew_period_id: nil,
        state_id: described_class::STATE_ID_ACTIVE
      }
    end
    let(:expected_attrs) do
      default_attributes.merge(create_params)
    end

    include_examples :creates_record do
      let(:expected_record_attrs) { expected_attrs }
    end

    context 'with variables' do
      let(:create_params) do
        super().merge(variables: { 'foo' => 'bar' })
      end

      include_examples :creates_record do
        let(:expected_record_attrs) { expected_attrs }
      end
    end

    context 'with provisioning_class=Billing::Provisioning::FreeMinutes' do
      let(:service_type_attrs) do
        super().merge(provisioning_class: 'Billing::Provisioning::FreeMinutes')
      end
      let(:expected_attrs) do
        super().merge(
          variables: { 'prefixes' => [], 'ignore_prefixes' => [] }
        )
      end

      include_examples :creates_record do
        let(:expected_record_attrs) { expected_attrs }
      end

      context 'with valid prefixes' do
        let(:create_params) do
          super().merge(
            variables: {
              'prefixes' => [
                { 'prefix' => '123', 'duration' => 60, 'exclude' => false },
                { 'prefix' => '124', 'duration' => 30, 'exclude' => true }
              ],
              'ignore_prefixes' => []
            }
          )
        end
        let(:expected_attrs) do
          default_attributes.merge(create_params)
        end

        include_examples :creates_record do
          let(:expected_record_attrs) { expected_attrs }
        end
      end

      context 'with invalid prefixes' do
        let(:create_params) do
          super().merge(
            variables: {
              'prefixes' => [
                { 'prefix' => '', 'duration' => 60 },
                { 'prefix' => nil, 'duration' => 60 },
                { 'prefix' => 112, 'duration' => 60 },
                { 'duration' => 60 },
                { 'prefix' => '114', 'duration' => '60' },
                { 'prefix' => '115', 'duration' => 'test' },
                { 'prefix' => '116', 'duration' => nil },
                { 'prefix' => '117' },
                { 'prefix' => '118', 'duration' => 60, 'exclude' => 'test' },
                { 'prefix' => '119', 'duration' => 60, 'exclude' => 123 },
                {}
              ],
              'ignore_prefixes' => [
                123,
                nil
              ]
            }
          )
        end

        include_examples :does_not_create_record, errors: {
          variables: [
            'prefixes.0.prefix - must be filled',
            'prefixes.1.prefix - must be a string',
            'prefixes.2.prefix - must be a string',
            'prefixes.3.prefix - is missing',
            'prefixes.4.duration - must be an integer',
            'prefixes.5.duration - must be an integer',
            'prefixes.6.duration - must be an integer',
            'prefixes.7.duration - is missing',
            'prefixes.8.exclude - must be boolean',
            'prefixes.9.exclude - must be boolean',
            'prefixes.10.prefix - is missing',
            'prefixes.10.duration - is missing',
            'ignore_prefixes.0 - must be a string',
            'ignore_prefixes.1 - must be a string'
          ]
        }
      end

      context 'with extra variables' do
        let(:create_params) do
          super().merge(variables: { 'foo' => 'bar' })
        end
        let(:expected_attrs) do
          super().merge(
            variables: { 'prefixes' => [], 'ignore_prefixes' => [] }
          )
        end

        include_examples :creates_record do
          let(:expected_record_attrs) { expected_attrs }
        end
      end
    end
  end
end

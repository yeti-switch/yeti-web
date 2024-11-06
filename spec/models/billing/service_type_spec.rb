# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.service_types
#
#  id                 :integer(2)       not null, primary key
#  force_renew        :boolean          default(FALSE), not null
#  name               :string           not null
#  provisioning_class :string
#  ui_type            :string
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
    it { is_expected.to allow_values('', nil, {}, { foo: 'bar' }).for(:variables) }
    it { is_expected.not_to allow_value('test').for(:variables) }
    it { is_expected.not_to allow_value([{ foo: 'bar' }]).for(:variables) }
    it { is_expected.not_to allow_value(123).for(:variables) }
    it { is_expected.not_to allow_value(true).for(:variables) }
  end

  describe '.create' do
    subject do
      described_class.create(create_params)
    end

    let(:create_params) do
      {
        name: 'test',
        provisioning_class: 'Billing::Provisioning::Logging'
      }
    end
    let(:default_attributes) do
      {
        variables: nil,
        force_renew: false
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
      let(:create_params) do
        super().merge(provisioning_class: 'Billing::Provisioning::FreeMinutes')
      end
      let(:expected_attrs) do
        super().merge(
          variables: { 'prefixes' => [] }
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
                { 'prefix' => '123', 'duration' => 60 },
                { 'prefix' => '124', 'duration' => 30, 'exclude' => true }
              ]
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
            'prefixes.10.duration - is missing'
          ]
        }
      end

      context 'with extra variables' do
        let(:create_params) do
          super().merge(variables: { 'foo' => 'bar' })
        end
        let(:expected_attrs) do
          super().merge(
            variables: { 'prefixes' => [] }
          )
        end

        include_examples :creates_record do
          let(:expected_record_attrs) { expected_attrs }
        end
      end
    end

    context 'with provisioning_class=Billing::Provisioning::PhoneSystems' do
      context 'when invalid data' do
        let(:create_params) { super().merge(provisioning_class: 'Billing::Provisioning::PhoneSystems') }

        include_examples :does_not_create_record, errors: {
          variables: [
            '.endpoint - is missing',
            '.username - is missing',
            '.password - is missing',
            '.attributes - is missing'
          ]
        }
      end

      context 'when valid data' do
        let(:create_params) do
          {
            name: 'test',
            provisioning_class: 'Billing::Provisioning::PhoneSystems',
            variables: {
              'endpoint' => 'https://api.telecom.center',
              'username' => 'test',
              'password' => 'test',
              'attributes' => {
                'name' => 'John Johnson',
                'language' => 'EN',
                'trm_mode' => 'operator',
                'capacity_limit' => 10,
                'sip_account_limit' => 5
              }
            }
          }
        end

        it_behaves_like :creates_record do
          let(:expected_record_attrs) { expected_attrs }
        end
      end
    end
  end
end

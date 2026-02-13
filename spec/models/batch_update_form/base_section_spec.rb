# frozen_string_literal: true

RSpec.describe BatchUpdateForm::Base do
  describe '.form_data_plain_array' do
    let(:timezones) do
      [
        'Pacific/Wallis',
        'Pacific/Yap',
        'Poland',
        'Portugal',
        'ROC',
        'ROK',
        'Singapore',
        'Turkey',
        'UCT',
        'US/Alaska',
        'US/Aleutian',
        'US/Arizona',
        'US/Central',
        'US/East-Indiana',
        'US/Eastern',
        'US/Hawaii',
        'US/Indiana-Starke',
        'US/Michigan',
        'US/Mountain',
        'US/Pacific',
        'US/Samoa',
        'UTC',
        'Universal',
        'W-SU',
        'WET',
        'Zulu'
      ]
    end

    it 'returns array of arrays where label and value are the same' do
      result = described_class.form_data_plain_array(collection: timezones)

      expect(result).to be_an(Array)
      expect(result.length).to eq(timezones.length)

      result.each_with_index do |item, index|
        expect(item).to be_an(Array)
        expect(item.length).to eq(2)
        expect(item[0]).to eq(timezones[index])
        expect(item[1]).to eq(timezones[index])
        expect(item[0]).to eq(item[1]) # label equals value
      end
    end

    it 'handles empty array' do
      result = described_class.form_data_plain_array(collection: [])

      expect(result).to eq([])
    end

    it 'handles single item array' do
      result = described_class.form_data_plain_array(collection: ['UTC'])

      expect(result).to eq([%w[UTC UTC]])
    end

    context 'when used in form_data' do
      let(:test_form_class) do
        Class.new(described_class) do
          attribute :timezone, type: :plain_array, collection: ['UTC', 'America/New_York', 'Europe/London']
        end
      end

      it 'returns correct format for plain_array type' do
        form_data = test_form_class.form_data

        expect(form_data[:timezone]).to eq([
                                             ['UTC', 'UTC'],
                                             ['America/New_York', 'America/New_York'],
                                             ['Europe/London', 'Europe/London']
                                           ])
      end
    end

    context 'when initializing form with plain_array attribute' do
      let(:test_form_class) do
        Class.new(described_class) do
          model_class 'Account'
          attribute :timezone, type: :plain_array, collection: ['UTC', 'America/New_York']
        end
      end

      it 'accepts and stores the value correctly' do
        form = test_form_class.new(timezone: 'UTC')

        expect(form.timezone).to eq('UTC')
        expect(form.timezone_changed?).to be true
      end

      it 'handles type casting correctly' do
        form = test_form_class.new(timezone: 'America/New_York')

        expect(form.timezone).to eq('America/New_York')
      end
    end
  end

  describe '#type_cast_plain_array' do
    let(:test_form_class) do
      Class.new(described_class) do
        model_class 'Account'
        attribute :timezone, type: :plain_array, collection: ['UTC']
      end
    end

    it 'returns the value as-is' do
      form = test_form_class.new
      result = form.type_cast_plain_array('UTC')

      expect(result).to eq('UTC')
    end

    it 'handles string values' do
      form = test_form_class.new
      result = form.type_cast_plain_array('America/New_York')

      expect(result).to eq('America/New_York')
    end
  end
end

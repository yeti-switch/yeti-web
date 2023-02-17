# frozen_string_literal: true

RSpec.describe RateManagement::PricelistItemsParser do
  subject { described_class.call(**service_params) }

  let(:service_params) { { file: csv_file, project: project } }

  let(:project) { FactoryBot.create(:rate_management_project, :filled, **project_attrs) }
  let(:project_attrs) { {} }
  let!(:routing_tags) { FactoryBot.create_list(:routing_tag, 3) }
  let(:routing_tag_mode) { Routing::RoutingTagMode.last! }

  shared_examples :returns_correct_result do
    it 'returns correct array of hashes' do
      expect(subject).to match_array(expected_result)
    end
  end

  let(:csv_headers) do
    [
      'Prefix', 'Initial Rate', 'Next Rate', 'Connect Fee', 'Dst Number Min Length', 'Dst Number Max Length',
      'Initial Interval', 'Next Interval', 'Routing Tag Names', 'Routing Tag Mode', 'Enabled', 'Priority', 'Valid From'
    ]
  end
  let(:csv_attrs_list) do
    [
      {
        prefix: '521',
        initial_rate: '1',
        next_rate: '2',
        connect_fee: '0.5',
        dst_number_min_length: '25',
        dst_number_max_length: '60',
        initial_interval: '1',
        next_interval: '2',
        routing_tag_names: "#{routing_tags.first.name},#{routing_tags.second.name},#{routing_tags.third.name}",
        routing_tag_mode: '0',
        enabled: 'TRUE',
        priority: '200',
        valid_from: 2.days.from_now.utc.to_s
      },
      {
        prefix: '',
        initial_rate: '2',
        next_rate: '3',
        connect_fee: '0.6',
        dst_number_min_length: nil,
        dst_number_max_length: nil,
        initial_interval: '1',
        next_interval: '2',
        routing_tag_names: "#{routing_tags.first.name},#{routing_tags.second.name},any tag",
        routing_tag_mode: nil,
        enabled: 'FALSE',
        priority: '100',
        valid_from: Time.now.utc.to_s
      },
      {
        prefix: '5125',
        initial_rate: '3',
        next_rate: '4',
        connect_fee: '0.7',
        dst_number_min_length: '25',
        dst_number_max_length: '60',
        initial_interval: nil,
        next_interval: '3',
        routing_tag_names: nil,
        routing_tag_mode: '0',
        enabled: nil,
        priority: '50',
        valid_from: nil
      },
      {
        prefix: '',
        initial_rate: '4',
        next_rate: '5',
        connect_fee: '0.8',
        dst_number_min_length: '25',
        dst_number_max_length: '60',
        initial_interval: '3',
        next_interval: nil,
        routing_tag_names: "#{routing_tags.first.name},#{routing_tags.second.name},#{routing_tags.third.name}",
        routing_tag_mode: '1',
        enabled: nil,
        priority: nil,
        valid_from: 2.days.from_now.utc.to_s
      }
    ]
  end
  let(:csv_file) do
    rows = csv_attrs_list.map do |attrs|
      csv_headers.map { |header| attrs[header&.parameterize&.underscore&.to_sym] }
    end
    create_csv_file(csv_headers, rows)
  end
  let(:expected_result) { csv_attrs_list }

  include_examples :returns_correct_result

  context 'when raise while parsing file' do
    before do
      allow(CSV).to receive(:parse).and_raise(error)
    end

    let(:error) { CSV::MalformedCSVError.new('Missing or stray quote', 1) }

    it 'should be raise validation error' do
      expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, error.message
    end
  end

  context 'when csv file has invalid header' do
    let(:csv_headers) do
      ['Invalid Header']
    end
    let(:csv_attrs_list) do
      [{ invalid_header: 'invalid_value' }]
    end

    it 'should be raise validation error' do
      expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, 'Unknown headers: Invalid header.' \
                            ' Valid headers are: Prefix, Initial rate, Next rate, Connect fee, Dst number min length,' \
                            ' Dst number max length, Initial interval, Next interval, Routing tag names,' \
                            ' Routing tag mode, Enabled, Priority, Valid from'
    end
  end

  context 'when csv file has several invalid headers' do
    let(:csv_headers) do
      ['Invalid Header', 'Test']
    end
    let(:csv_attrs_list) do
      [{ invalid_header: 'invalid_value', test: '123' }]
    end

    it 'should be raise validation error' do
      expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, 'Unknown headers: Invalid header, Test.' \
                            ' Valid headers are: Prefix, Initial rate, Next rate, Connect fee, Dst number min length,' \
                            ' Dst number max length, Initial interval, Next interval, Routing tag names,' \
                            ' Routing tag mode, Enabled, Priority, Valid from'
    end
  end

  context 'when CSV file has no headers' do
    let(:csv_file) do
      create_csv_file([nil, 'test'], [%w[test1 test2], %w[test3 test4]])
    end

    it 'should be raise validation error' do
      expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, 'Headers required'
    end
  end

  context 'when Prefix header is missing' do
    let(:csv_headers) { super() - ['Prefix'] }

    it 'should be raise validation error' do
      expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, 'Missing mandatory headers: Prefix.'
    end
  end

  context 'when Initial rate header is missing' do
    let(:csv_headers) { super() - ['Initial Rate'] }

    it 'should be raise validation error' do
      expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, 'Missing mandatory headers: Initial rate.'
    end
  end

  context 'when Next Rate header is missing' do
    let(:csv_headers) { super() - ['Next Rate'] }

    it 'should be raise validation error' do
      expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, 'Missing mandatory headers: Next rate.'
    end
  end

  context 'when Connect Fee header is missing' do
    let(:csv_headers) { super() - ['Connect Fee'] }

    it 'should be raise validation error' do
      expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, 'Missing mandatory headers: Connect fee.'
    end
  end

  context 'when Dst Number Min Length header is missing' do
    let(:csv_headers) { super() - ['Dst Number Min Length'] }
    let(:csv_attrs_list) do
      super().map { |row| row.except(:dst_number_min_length) }
    end

    include_examples :returns_correct_result
  end

  context 'when Dst Number Max Length header is missing' do
    let(:csv_headers) { super() - ['Dst Number Max Length'] }
    let(:csv_attrs_list) do
      super().map { |row| row.except(:dst_number_max_length) }
    end

    include_examples :returns_correct_result
  end

  context 'when Initial Interval header is missing' do
    let(:csv_headers) { super() - ['Initial Interval'] }
    let(:csv_attrs_list) do
      super().map { |row| row.except(:initial_interval) }
    end

    context 'when project has filled initial_interval' do
      let(:project_attrs) { super().merge initial_interval: 60 }

      include_examples :returns_correct_result
    end

    context 'when project has empty initial_interval' do
      let(:project_attrs) { super().merge initial_interval: nil }

      it 'should be raise validation error' do
        expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, 'Missing mandatory headers: Initial interval.'
      end
    end
  end

  context 'when Next Interval header is missing' do
    let(:csv_headers) { super() - ['Next Interval'] }
    let(:csv_attrs_list) do
      super().map { |row| row.except(:next_interval) }
    end

    context 'when project has filled next_interval' do
      let(:project_attrs) { super().merge next_interval: 60 }

      include_examples :returns_correct_result
    end

    context 'when project has empty next_interval' do
      let(:project_attrs) { super().merge next_interval: nil }

      it 'should be raise validation error' do
        expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, 'Missing mandatory headers: Next interval.'
      end
    end
  end

  context 'when Routing Tag Names header is missing' do
    let(:csv_headers) { super() - ['Routing Tag Names'] }
    let(:csv_attrs_list) do
      super().map { |row| row.except(:routing_tag_names) }
    end

    context 'when project has filled routing_tag_ids' do
      let(:project_attrs) { super().merge routing_tag_ids: [routing_tags.first.id] }

      include_examples :returns_correct_result
    end

    context 'when project has empty routing_tag_ids' do
      let(:project_attrs) { super().merge routing_tag_ids: [] }

      include_examples :returns_correct_result
    end
  end

  context 'when Routing Tag Mode header is missing' do
    let(:csv_headers) { super() - ['Routing Tag Mode'] }
    let(:csv_attrs_list) do
      super().map { |row| row.except(:routing_tag_mode) }
    end

    context 'when project has filled routing_tag_mode_id' do
      let(:project_attrs) { super().merge routing_tag_mode_id: 1 }

      include_examples :returns_correct_result
    end

    context 'when project has empty routing_tag_mode_id' do
      let(:project_attrs) { super().merge routing_tag_mode_id: nil }

      it 'should be raise validation error' do
        expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error, 'Missing mandatory headers: Routing tag mode.'
      end
    end
  end

  context 'when Enabled header is missing' do
    let(:csv_headers) { super() - ['Enabled'] }
    let(:csv_attrs_list) do
      super().map { |row| row.except(:enabled) }
    end

    include_examples :returns_correct_result
  end

  context 'when Priority header is missing' do
    let(:csv_headers) { super() - ['Priority'] }
    let(:csv_attrs_list) do
      super().map { |row| row.except(:priority) }
    end

    include_examples :returns_correct_result
  end

  context 'when Valid From header is missing' do
    let(:csv_headers) { super() - ['Valid From'] }
    let(:csv_attrs_list) do
      super().map { |row| row.except(:valid_from) }
    end

    include_examples :returns_correct_result
  end

  context 'when missing several mandatory headers' do
    let(:csv_headers) { super() - ['Prefix', 'Next Rate'] }

    it 'should be raise validation error' do
      expect { subject }.to raise_error RateManagement::PricelistItemsParser::Error,
                                        'Missing mandatory headers: Prefix, Next rate.'
    end
  end
end

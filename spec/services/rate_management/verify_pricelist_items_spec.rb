# frozen_string_literal: true

RSpec.describe RateManagement::VerifyPricelistItems do
  subject do
    described_class.call(**service_params)
  end

  shared_examples :raises_service_error do |error_lines|
    it 'raises RateManagement::VerifyPricelistItems::Error with correct error lines' do
      expect { subject }.to raise_error(RateManagement::VerifyPricelistItems::Error) do |e|
        expect(e.error_lines).to be_present
        expect(e.error_lines).to match_array(
                                   Array.wrap(error_lines)
                                 )
      end
    end
  end

  shared_examples :returns_item_attrs_list do
    it 'returns items attrs list' do
      expect(subject).to be_present
      expect(subject).to match(
                           Array.wrap(expected_pricelist_item_attrs)
                         )
    end
  end

  let(:service_params) do
    {
      pricelist: pricelist,
      attributes_list: csv_rows
    }
  end

  let!(:project) { FactoryBot.create(:rate_management_project, :filled, :with_routing_tags, **project_attrs) }
  let(:project_attrs) { {} }
  let!(:pricelist) { FactoryBot.create(:rate_management_pricelist, **pricelist_attrs) }
  let(:pricelist_attrs) { { project: project } }
  let!(:routing_tags) { FactoryBot.create_list(:routing_tag, 3) }
  let(:default_item_attrs) do
    {
      pricelist_id: pricelist.id,
      valid_till: pricelist.valid_till,
      src_rewrite_rule: project.src_rewrite_rule,
      dst_rewrite_rule: project.dst_rewrite_rule,
      src_rewrite_result: project.src_rewrite_result,
      dst_rewrite_result: project.dst_rewrite_result,
      src_name_rewrite_rule: project.src_name_rewrite_rule,
      src_name_rewrite_result: project.src_name_rewrite_result,
      acd_limit: project.acd_limit,
      asr_limit: project.asr_limit,
      capacity: project.capacity,
      lcr_rate_multiplier: project.lcr_rate_multiplier,
      force_hit_rate: project.force_hit_rate,
      short_calls_limit: project.short_calls_limit,
      exclusive_route: project.exclusive_route,
      reverse_billing: project.reverse_billing,
      account_id: project.account_id,
      vendor_id: project.vendor_id,
      routing_group_id: project.routing_group_id,
      routeset_discriminator_id: project.routeset_discriminator_id,
      gateway_id: project.gateway_id,
      gateway_group_id: project.gateway_group_id
    }
  end

  context 'with several rows' do
    let(:csv_rows) do
      [
        {
          prefix: '523',
          initial_rate: '1',
          next_rate: '2',
          connect_fee: '0.5',
          dst_number_min_length: '25',
          dst_number_max_length: '60',
          initial_interval: '1',
          next_interval: '2',
          routing_tag_names: "#{routing_tags.first.name},#{routing_tags.second.name},any tag",
          routing_tag_mode: 'AND',
          enabled: 'TRUE',
          priority: '200',
          valid_from: 2.days.from_now.beginning_of_day.strftime('%F %T')
        },
        {
          prefix: '524',
          initial_rate: '0.5',
          next_rate: '0.3',
          connect_fee: '1.1',
          dst_number_min_length: '10',
          dst_number_max_length: '20',
          initial_interval: '1',
          next_interval: '60',
          routing_tag_names: 'any tag',
          routing_tag_mode: 'OR',
          enabled: 'FALSE',
          priority: '100',
          valid_from: 1.day.from_now.strftime('%F')
        },
        {
          prefix: '',
          initial_rate: '2',
          next_rate: '3',
          connect_fee: '0.6',
          dst_number_min_length: nil,
          dst_number_max_length: nil,
          initial_interval: nil,
          next_interval: nil,
          routing_tag_names: nil,
          routing_tag_mode: nil,
          enabled: nil,
          priority: nil,
          valid_from: nil
        }
      ]
    end
    let(:expected_pricelist_item_attrs) do
      [
        {
          prefix: '523',
          initial_rate: 1,
          next_rate: 2,
          connect_fee: 0.5,
          dst_number_min_length: 25,
          dst_number_max_length: 60,
          initial_interval: 1,
          next_interval: 2,
          routing_tag_ids: [routing_tags.first.id, routing_tags.second.id, nil],
          routing_tag_mode_id: Routing::RoutingTagMode::CONST::AND,
          enabled: true,
          priority: 200,
          valid_from: 2.days.from_now.beginning_of_day,
          **default_item_attrs
        },
        {
          prefix: '524',
          initial_rate: 0.5,
          next_rate: 0.3,
          connect_fee: 1.1,
          dst_number_min_length: 10,
          dst_number_max_length: 20,
          initial_interval: 1,
          next_interval: 60,
          routing_tag_ids: [nil],
          routing_tag_mode_id: Routing::RoutingTagMode::CONST::OR,
          enabled: false,
          priority: 100,
          valid_from: 1.day.from_now.beginning_of_day,
          **default_item_attrs
        },
        {
          prefix: '',
          initial_rate: 2,
          next_rate: 3,
          connect_fee: 0.6,
          dst_number_min_length: project.dst_number_min_length,
          dst_number_max_length: project.dst_number_max_length,
          initial_interval: project.initial_interval,
          next_interval: project.next_interval,
          routing_tag_ids: project.routing_tag_ids,
          routing_tag_mode_id: project.routing_tag_mode_id,
          enabled: nil,
          priority: nil,
          valid_from: nil,
          **default_item_attrs
        }
      ]
    end

    include_examples :returns_item_attrs_list
  end

  context 'with one row' do
    let(:csv_rows) { [item_attrs] }
    let(:item_attrs) do
      {
        prefix: '523',
        initial_rate: '1',
        next_rate: '2',
        connect_fee: '0.5',
        dst_number_min_length: '25',
        dst_number_max_length: '60',
        initial_interval: '1',
        next_interval: '2',
        routing_tag_names: "#{routing_tags.first.name},#{routing_tags.second.name},any tag",
        routing_tag_mode: 'AND',
        enabled: 'TRUE',
        priority: '100',
        valid_from: nil
      }
    end
    let(:expected_pricelist_item_attrs) do
      {
        prefix: '523',
        initial_rate: 1,
        next_rate: 2,
        connect_fee: 0.5,
        dst_number_min_length: 25,
        dst_number_max_length: 60,
        initial_interval: 1,
        next_interval: 2,
        routing_tag_ids: [routing_tags.first.id, routing_tags.second.id, nil],
        routing_tag_mode_id: Routing::RoutingTagMode::CONST::AND,
        enabled: true,
        priority: 100,
        valid_from: nil,
        **default_item_attrs
      }
    end

    context 'when CSV has not sorted routing_tag_names' do
      let(:item_attrs) do
        {
          prefix: '523',
          initial_rate: '1',
          next_rate: '2',
          connect_fee: '0.5',
          dst_number_min_length: '25',
          dst_number_max_length: '60',
          initial_interval: '1',
          next_interval: '2',
          routing_tag_names: "#{routing_tags.third.name},any tag,#{routing_tags.first.name}",
          routing_tag_mode: 'AND',
          valid_from: nil
        }
      end
      let(:expected_pricelist_item_attrs) do
        {
          prefix: '523',
          initial_rate: 1,
          next_rate: 2,
          connect_fee: 0.5,
          dst_number_min_length: 25,
          dst_number_max_length: 60,
          initial_interval: 1,
          next_interval: 2,
          routing_tag_ids: [routing_tags.first.id, routing_tags.third.id, nil],
          routing_tag_mode_id: Routing::RoutingTagMode::CONST::AND,
          enabled: nil,
          priority: nil,
          valid_from: nil,
          **default_item_attrs
        }
      end

      include_examples :returns_item_attrs_list
    end

    context 'when csv_rows has duplicate in 2 rows' do
      let(:csv_rows) do
        [
          item_attrs.merge(prefix: '111'),
          item_attrs,
          item_attrs.merge(prefix: '112'),
          item_attrs.merge(routing_tag_names: "#{routing_tags.first.name},#{routing_tags.second.name}"),
          item_attrs
        ]
      end

      include_examples :raises_service_error, 'has duplicates for row 3:6'
    end

    context 'when csv_rows has duplicates on 3 rows and another duplicate in 2 rows' do
      let(:csv_rows) do
        [
          item_attrs.merge(prefix: '111', routing_tag_names: "#{routing_tags.first.name},#{routing_tags.second.name}"),
          item_attrs,
          item_attrs,
          item_attrs.merge(prefix: '112'),
          item_attrs.merge(routing_tag_names: "#{routing_tags.first.name},#{routing_tags.second.name}"),
          item_attrs,
          item_attrs.merge(prefix: '111', routing_tag_names: "#{routing_tags.second.name},#{routing_tags.first.name}")
        ]
      end

      include_examples :raises_service_error, 'has duplicates for rows 2:8, 3:4:7'
    end

    context 'when CSV has row with prefix contain whitespace' do
      let(:item_attrs) { super().merge(prefix: ' ') }

      include_examples :raises_service_error, 'Prefix space is not allowed for row 2'
    end

    context 'when CSV has row with blank prefix' do
      let(:item_attrs) { super().merge(prefix: nil) }

      include_examples :raises_service_error, 'Prefix must be exist for row 2'
    end

    context 'when CSV has row with blank initial_rate' do
      let(:item_attrs) { super().merge(initial_rate: nil) }

      include_examples :raises_service_error, "Initial rate can't be blank for row 2"
    end

    context 'when CSV has row with blank next_rate' do
      let(:item_attrs) { super().merge(next_rate: nil) }

      include_examples :raises_service_error, "Next rate can't be blank for row 2"
    end

    context 'when CSV has row with dst_number_min_length="-1"' do
      let(:item_attrs) { super().merge(dst_number_min_length: -1) }

      include_examples :raises_service_error, 'Dst number min length must be greater or equal to 0 and less or equal to 100 for row 2'
    end

    context 'when CSV has row with dst_number_min_length="101"' do
      let(:item_attrs) { super().merge(dst_number_min_length: 101) }

      include_examples :raises_service_error, 'Dst number min length must be greater or equal to 0 and less or equal to 100 for row 2'
    end

    context 'when CSV has row with dst_number_min_length=""' do
      let(:item_attrs) { super().merge(dst_number_min_length: nil) }
      let(:expected_pricelist_item_attrs) do
        super().merge dst_number_min_length: project.dst_number_min_length
      end

      include_examples :returns_item_attrs_list
    end

    context 'when CSV row has dst_number_min_length="1.23"' do
      let(:item_attrs) { super().merge(dst_number_min_length: '1.23') }

      include_examples :raises_service_error, 'Dst number min length must be an integer for row 2'
    end

    context 'when CSV has row with dst_number_min_length="test"' do
      let(:item_attrs) { super().merge(dst_number_min_length: 'test') }

      include_examples :raises_service_error, 'Dst number min length must be an integer for row 2'
    end

    context 'when CSV has row with dst_number_max_length="-1"' do
      let(:item_attrs) { super().merge(dst_number_max_length: -1) }

      include_examples :raises_service_error, 'Dst number max length must be greater or equal to 0 and less or equal to 100 for row 2'
    end

    context 'when CSV has row with dst_number_max_length="101"' do
      let(:item_attrs) { super().merge(dst_number_max_length: 101) }

      include_examples :raises_service_error, 'Dst number max length must be greater or equal to 0 and less or equal to 100 for row 2'
    end

    context 'when CSV has row with dst_number_max_length=""' do
      let(:item_attrs) { super().merge(dst_number_max_length: nil) }
      let(:expected_pricelist_item_attrs) do
        super().merge dst_number_max_length: project.dst_number_max_length
      end

      include_examples :returns_item_attrs_list
    end

    context 'when CSV row has dst_number_max_length="1.23"' do
      let(:item_attrs) { super().merge(dst_number_max_length: '1.23') }

      include_examples :raises_service_error, 'Dst number max length must be an integer for row 2'
    end

    context 'when CSV has row with dst_number_max_length="test"' do
      let(:item_attrs) { super().merge(dst_number_max_length: 'test') }

      include_examples :raises_service_error, 'Dst number max length must be an integer for row 2'
    end

    context 'when CSV has row with initial_interval=""' do
      let(:item_attrs) { super().merge(initial_interval: nil) }

      context 'whe project has filled initial_interval' do
        let(:project_attrs) { super().merge(initial_interval: 60) }
        let(:expected_pricelist_item_attrs) do
          super().merge initial_interval: project.initial_interval
        end

        include_examples :returns_item_attrs_list
      end

      context 'whe project has initial_interval=null' do
        let(:project_attrs) { super().merge(initial_interval: nil) }

        include_examples :raises_service_error, "Initial interval can't be blank for row 2"
      end
    end

    context 'when CSV has row with initial_interval="-1"' do
      let(:item_attrs) { super().merge(initial_interval: -1) }

      include_examples :raises_service_error, 'Initial interval must be greater or equal to 0 for row 2'
    end

    context 'when CSV row has initial_interval="1.23"' do
      let(:item_attrs) { super().merge(initial_interval: '1.23') }

      include_examples :raises_service_error, 'Initial interval must be an integer for row 2'
    end

    context 'when CSV has row with initial_interval="test"' do
      let(:item_attrs) { super().merge(initial_interval: 'test') }

      include_examples :raises_service_error, 'Initial interval must be an integer for row 2'
    end

    context 'when CSV has row with next_interval=""' do
      let(:item_attrs) { super().merge(next_interval: nil) }

      context 'whe project has filled next_interval' do
        let(:project_attrs) { super().merge(initial_interval: 60) }
        let(:expected_pricelist_item_attrs) do
          super().merge next_interval: project.next_interval
        end

        include_examples :returns_item_attrs_list
      end

      context 'whe project has next_interval=null' do
        let(:project_attrs) { super().merge(next_interval: nil) }

        include_examples :raises_service_error, "Next interval can't be blank for row 2"
      end
    end

    context 'when CSV has row with next_interval="-1"' do
      let(:item_attrs) { super().merge(next_interval: -1) }

      include_examples :raises_service_error, 'Next interval must be greater or equal to 0 for row 2'
    end

    context 'when CSV row has next_interval="1.23"' do
      let(:item_attrs) { super().merge(next_interval: '1.23') }

      include_examples :raises_service_error, 'Next interval must be an integer for row 2'
    end

    context 'when CSV has row with next_interval="test"' do
      let(:item_attrs) { super().merge(next_interval: 'test') }

      include_examples :raises_service_error, 'Next interval must be an integer for row 2'
    end

    context 'when CSV row has routing_tag_names=""' do
      let(:item_attrs) { super().merge(routing_tag_names: nil) }

      context 'when project has routing_tag_ids filled' do
        let(:project_attrs) do
          super().merge(routing_tag_ids: [routing_tags.third.id, routing_tags.first.id])
        end
        let(:expected_pricelist_item_attrs) do
          super().merge routing_tag_ids: [routing_tags.first.id, routing_tags.third.id]
        end

        include_examples :returns_item_attrs_list
      end

      context 'when project has routing_tag_ids=[]' do
        let(:project_attrs) { super().merge(routing_tag_ids: []) }
        let(:expected_pricelist_item_attrs) do
          super().merge routing_tag_ids: []
        end

        include_examples :returns_item_attrs_list
      end
    end

    context 'when CSV row has routing_tag_names="not tagged"' do
      let(:item_attrs) { super().merge(routing_tag_names: 'not tagged') }
      let(:expected_pricelist_item_attrs) do
        super().merge routing_tag_ids: []
      end

      context 'when project has routing_tag_ids filled' do
        let(:project_attrs) do
          super().merge(routing_tag_ids: [routing_tags.third.id, routing_tags.first.id])
        end

        include_examples :returns_item_attrs_list
      end

      context 'when project has routing_tag_ids=[]' do
        let(:project_attrs) { super().merge(routing_tag_ids: []) }

        include_examples :returns_item_attrs_list
      end
    end

    context 'when CSV row has routing_tag_names="tag1,tag2"' do
      let(:item_attrs) do
        super().merge(routing_tag_names: "#{routing_tags.first.name},#{routing_tags.second.name}")
      end
      let(:expected_pricelist_item_attrs) do
        super().merge routing_tag_ids: [routing_tags.first.id, routing_tags.second.id]
      end

      context 'when project has routing_tag_ids filled' do
        let(:project_attrs) do
          super().merge(routing_tag_ids: [routing_tags.third.id, routing_tags.first.id])
        end

        include_examples :returns_item_attrs_list
      end

      context 'when project has routing_tag_ids=[]' do
        let(:project_attrs) { super().merge(routing_tag_ids: []) }

        include_examples :returns_item_attrs_list
      end
    end

    context 'when CSV row has routing_tag_names="tag2,any tag,tag1"' do
      let(:item_attrs) do
        super().merge(routing_tag_names: "#{routing_tags.second.name},any tag,#{routing_tags.first.name}")
      end
      let(:expected_pricelist_item_attrs) do
        super().merge routing_tag_ids: [routing_tags.first.id, routing_tags.second.id, nil]
      end

      context 'when project has routing_tag_ids filled' do
        let(:project_attrs) do
          super().merge(routing_tag_ids: [routing_tags.third.id, routing_tags.first.id])
        end

        include_examples :returns_item_attrs_list
      end

      context 'when project has routing_tag_ids=[]' do
        let(:project_attrs) { super().merge(routing_tag_ids: []) }

        include_examples :returns_item_attrs_list
      end
    end

    context 'when CSV row has routing_tag_names invalid' do
      let(:item_attrs) { super().merge(routing_tag_names: 'Invalid') }

      include_examples :raises_service_error, 'Routing tag names are invalid for row 2'
    end

    context 'when CSV row has blank routing_tag_mode' do
      let(:item_attrs) { super().merge(routing_tag_mode: nil) }

      context 'when project has blank routing_tag_mode_id' do
        let(:project_attrs) { super().merge routing_tag_mode_id: nil }

        include_examples :raises_service_error, "Routing tag mode can't be blank for row 2"
      end

      context 'when project has filled routing_tag_mode_id' do
        let(:project_attrs) do
          super().merge routing_tag_mode_id: Routing::RoutingTagMode::CONST::AND
        end

        include_examples :returns_item_attrs_list
      end
    end

    context 'when CSV row has invalid routing_tag_mode' do
      let(:item_attrs) { super().merge(routing_tag_mode: 'Invalid') }

      include_examples :raises_service_error, 'Routing tag mode is invalid for row 2'
    end

    context 'when CSV row has enabled=TRUE' do
      let(:item_attrs) { super().merge(enabled: 'TRUE') }
      let(:expected_pricelist_item_attrs) do
        super().merge enabled: true
      end

      context 'when project has enabled=false' do
        let(:project_attrs) do
          super().merge enabled: false
        end

        include_examples :returns_item_attrs_list
      end

      context 'when project has enabled=true' do
        let(:project_attrs) do
          super().merge enabled: true
        end

        include_examples :returns_item_attrs_list
      end
    end

    context 'when CSV row has enabled=FALSE' do
      let(:item_attrs) { super().merge(enabled: 'FALSE') }
      let(:expected_pricelist_item_attrs) do
        super().merge enabled: false
      end

      context 'when project has enabled=false' do
        let(:project_attrs) do
          super().merge enabled: false
        end

        include_examples :returns_item_attrs_list
      end

      context 'when project has enabled=true' do
        let(:project_attrs) do
          super().merge enabled: true
        end

        include_examples :returns_item_attrs_list
      end
    end

    context 'when CSV row has enabled=""' do
      let(:item_attrs) { super().merge(enabled: nil) }
      let(:expected_pricelist_item_attrs) do
        super().merge enabled: nil
      end

      context 'when project has enabled=false' do
        let(:project_attrs) do
          super().merge enabled: false
        end

        include_examples :returns_item_attrs_list
      end

      context 'when project has enabled=true' do
        let(:project_attrs) do
          super().merge enabled: true
        end

        include_examples :returns_item_attrs_list
      end
    end

    context 'when CSV row has enabled=invalid' do
      let(:item_attrs) { super().merge(enabled: 'invalid') }

      include_examples :raises_service_error, 'Enabled is invalid for row 2'
    end

    context 'when CSV row has priority="123"' do
      let(:item_attrs) { super().merge(priority: '123') }
      let(:expected_pricelist_item_attrs) do
        super().merge priority: 123
      end

      include_examples :returns_item_attrs_list
    end

    context 'when CSV row has priority=""' do
      let(:item_attrs) { super().merge(priority: nil) }
      let(:expected_pricelist_item_attrs) do
        super().merge priority: nil
      end

      include_examples :returns_item_attrs_list
    end

    context 'when CSV row has priority="1.23"' do
      let(:item_attrs) { super().merge(priority: '1.23') }

      include_examples :raises_service_error, 'Priority must be an integer for row 2'
    end

    context 'when CSV row has priority="test"' do
      let(:item_attrs) { super().merge(priority: 'test') }

      include_examples :raises_service_error, 'Priority must be an integer for row 2'
    end

    context 'when CSV row has valid_from=""' do
      let(:item_attrs) { super().merge(valid_from: nil) }

      context 'when pricelist has valid_from' do
        let(:pricelist_attrs) do
          super().merge valid_from: 2.days.from_now.beginning_of_day
        end
        let(:expected_pricelist_item_attrs) { super().merge(valid_from: pricelist.valid_from) }

        include_examples :returns_item_attrs_list
      end

      context 'when pricelist has valid_from=nil' do
        let(:pricelist_attrs) { super().merge(valid_from: nil) }
        let(:expected_pricelist_item_attrs) { super().merge(valid_from: nil) }

        include_examples :returns_item_attrs_list
      end
    end

    context 'when CSV row has correct valid_from' do
      let(:item_attrs) do
        super().merge valid_from: 1.day.from_now.beginning_of_day.strftime('%F %T')
      end
      let(:expected_pricelist_item_attrs) do
        super().merge valid_from: 1.day.from_now.beginning_of_day
      end

      context 'when pricelist has valid_from' do
        let(:pricelist_attrs) do
          super().merge valid_from: 2.days.from_now.beginning_of_day
        end

        include_examples :returns_item_attrs_list
      end

      context 'when pricelist has valid_from=nil' do
        let(:pricelist_attrs) { super().merge(valid_from: nil) }

        include_examples :returns_item_attrs_list
      end
    end

    context 'when CSV row has valid_from=now' do
      let(:item_attrs) { super().merge(valid_from: Time.zone.now.to_s(:db)) }

      include_examples :raises_service_error, 'Valid from must be in future for row 2'
    end

    context 'when CSV row has valid_from is in the past' do
      let(:item_attrs) { super().merge(valid_from: 1.second.ago.to_s(:db)) }

      include_examples :raises_service_error, 'Valid from must be in future for row 2'
    end

    context 'when CSV row has valid_from=invalid' do
      let(:item_attrs) { super().merge(valid_from: 'invalid') }

      include_examples :raises_service_error, 'Valid from is invalid for row 2'
    end

    context 'when CSV row has valid_from = pricelist.valid_till' do
      let(:valid_till) { 1.month.from_now.round }
      let(:pricelist_attrs) { super().merge valid_till: valid_till }
      let(:item_attrs) do
        super().merge valid_from: valid_till.strftime('%F %T')
      end

      include_examples :raises_service_error, 'Valid from must be less than Pricelist Valid till for row 2'
    end

    context 'when CSV row has valid_from > pricelist.valid_till' do
      let(:valid_till) { 1.month.from_now.round }
      let(:pricelist_attrs) { super().merge valid_till: valid_till }
      let(:item_attrs) do
        super().merge valid_from: (valid_till + 1.minute).strftime('%F %T')
      end

      include_examples :raises_service_error, 'Valid from must be less than Pricelist Valid till for row 2'
    end

    context 'with few errors in same time' do
      let(:project_attrs) { super().merge(routing_tag_mode_id: nil) }
      let(:item_attrs) { super().merge(routing_tag_mode: nil, initial_rate: nil) }
      let(:csv_rows) do
        [
          item_attrs,
          item_attrs.merge(prefix: '524')
        ]
      end

      include_examples :raises_service_error, [
        "Initial rate can't be blank for rows 2, 3",
        "Routing tag mode can't be blank for rows 2, 3"
      ]
    end
  end
end

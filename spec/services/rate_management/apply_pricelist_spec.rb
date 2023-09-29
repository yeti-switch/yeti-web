# frozen_string_literal: true

RSpec.describe RateManagement::ApplyPricelist do
  subject { described_class.call(**service_params) }

  let(:service_params) { { pricelist: pricelist } }
  let(:project) { pricelist.project }
  let(:pricelist) { FactoryBot.create(:rate_management_pricelist, :with_project, state, **pricelist_attrs) }
  let(:pricelist_attrs) { { valid_till: valid_till, valid_from: valid_from, apply_changes_in_progress: true } }
  let(:state) { :dialpeers_detected }
  let(:valid_from) { Date.tomorrow }
  let(:valid_till) { 2.days.from_now.beginning_of_day }

  shared_examples :performs_apply_changes_successfully do
    it 'performs apply changes successfully' do
      subject
      expect(pricelist.reload).to have_attributes(
                                    state_id: RateManagement::Pricelist::CONST::STATE_ID_APPLIED,
                                    apply_changes_in_progress: false
                                  )
    end
  end

  shared_examples :apply_changes_failed do |error_message|
    it 'should raise error' do
      expect { subject }.to raise_error RateManagement::ApplyPricelist::Error, error_message
    end

    it 'does not change pricelist' do
      expect { safe_subject }.not_to change { pricelist.reload.attributes }
    end
  end

  include_examples :performs_apply_changes_successfully

  context 'create dialpeers' do
    let!(:to_create_items) do
      [
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, valid_from: nil, prefix: 12_345),
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, valid_from: nil),
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, valid_from: 1.day.ago),
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, valid_from: 1.day.from_now)
      ]
    end

    it 'updates valid_from for to_create items' do
      old_valid_from_3 = to_create_items[3].valid_from
      subject
      to_create_items.each(&:reload)
      expect(to_create_items[0]).to have_attributes valid_from: be_within(5).of(Time.zone.now) # was null
      expect(to_create_items[1]).to have_attributes valid_from: be_within(5).of(Time.zone.now) # was null
      expect(to_create_items[2]).to have_attributes valid_from: be_within(5).of(Time.zone.now) # was in past
      expect(to_create_items[3]).to have_attributes valid_from: be_within(0.001).of(old_valid_from_3)
    end

    it 'should be create new dialpeers' do
      expect { subject }.to change(Dialpeer, :count).by(to_create_items.size)
      new_dialpeers = Dialpeer.last(to_create_items.size)
      new_dialpeers.each_with_index do |dialpeer, index|
        item = to_create_items[index].reload
        expect(dialpeer).to have_attributes(
                              enabled: item.enabled,
                              prefix: item.prefix,
                              src_rewrite_rule: item.src_rewrite_rule,
                              dst_rewrite_rule: item.dst_rewrite_rule,
                              acd_limit: item.acd_limit,
                              asr_limit: item.asr_limit,
                              gateway_id: item.gateway_id,
                              routing_group_id: item.routing_group_id,
                              next_rate: item.next_rate,
                              connect_fee: item.connect_fee,
                              vendor_id: item.vendor_id,
                              account_id: item.account_id,
                              src_rewrite_result: item.src_rewrite_result,
                              dst_rewrite_result: item.dst_rewrite_result,
                              priority: item.priority,
                              capacity: item.capacity,
                              lcr_rate_multiplier: item.lcr_rate_multiplier,
                              initial_rate: item.initial_rate,
                              initial_interval: item.initial_interval,
                              next_interval: item.next_interval,
                              valid_from: item.valid_from,
                              valid_till: item.valid_till,
                              gateway_group_id: item.gateway_group_id,
                              force_hit_rate: item.force_hit_rate,
                              short_calls_limit: item.short_calls_limit,
                              src_name_rewrite_rule: item.src_name_rewrite_rule,
                              src_name_rewrite_result: item.src_name_rewrite_result,
                              exclusive_route: item.exclusive_route,
                              dst_number_min_length: item.dst_number_min_length,
                              dst_number_max_length: item.dst_number_max_length,
                              reverse_billing: item.reverse_billing,
                              routing_tag_ids: item.routing_tag_ids,
                              routing_tag_mode_id: item.routing_tag_mode_id,
                              routeset_discriminator_id: item.routeset_discriminator_id
                            )
      end
    end

    include_examples :performs_apply_changes_successfully

    context 'with network prefix' do
      let!(:network_prefix) do
        System::NetworkPrefix.delete_all
        FactoryBot.create(:network_prefix, prefix: 1234)
      end

      it 'should create dialpeer with network prefix' do
        subject
        dialpeer = Dialpeer.find_by(prefix: to_create_items.first.prefix)
        expect(dialpeer.network_prefix).to eq(network_prefix)
      end

      context 'with another network prefixes' do
        let!(:another_network_prefixes) do
          [
            FactoryBot.create(:network_prefix, prefix: 123),
            FactoryBot.create(:network_prefix, prefix: 12),
            FactoryBot.create(:network_prefix, prefix: 1)
          ]
        end

        it 'should create dialpeer with network prefix' do
          subject
          dialpeer = Dialpeer.find_by(prefix: to_create_items.first.prefix)
          expect(dialpeer.network_prefix).to eq(network_prefix)
        end
      end
    end
  end

  context 'delete dialpeers' do
    let!(:to_delete_items) do
      to_delete_dialpeers.map do |dialpeer|
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, dialpeer: dialpeer, detected_dialpeer_ids: [dialpeer.id], to_delete: true)
      end
    end
    let(:to_delete_dialpeers) { FactoryBot.create_list(:dialpeer, 3, valid_from: dialpeer_valid_from) }

    shared_examples :should_delete_dialpeers do
      it 'should delete dialpeers' do
        expect(DeleteDialpeers).to receive(:call).with(dialpeer_ids: match_array(to_delete_dialpeers.map(&:id))).and_call_original
        expect { subject }.to change(Dialpeer, :count).by(-to_delete_dialpeers.size)
      end
    end

    shared_examples :should_update_dialpeers do
      it 'should update dialpeers' do
        subject

        to_delete_items.each(&:reload)

        to_delete_dialpeers.each_with_index do |dialpeer, index|
          expect(dialpeer.reload.valid_till).to eq(to_delete_items[index].valid_from)
        end
      end
    end

    shared_examples :updates_to_delete_items do
      it 'clears dialpeer_id for to_delete items' do
        subject
        to_delete_items.each_with_index do |item, index|
          expect(item.reload).to have_attributes(
                                   dialpeer_id: nil,
                                   detected_dialpeer_ids: [to_delete_dialpeers[index].id],
                                   valid_from: be_present
                                 )
        end
      end
    end

    shared_examples :remove_dialpeer_next_rate do
      let!(:next_rates) do
        [
          FactoryBot.create(:dialpeer_next_rate, dialpeer: to_delete_dialpeers.first),
          FactoryBot.create(:dialpeer_next_rate, dialpeer: to_delete_dialpeers.second)
        ]
      end

      it 'should remove next rates' do
        expect { subject }.to change(DialpeerNextRate, :count).by(-next_rates.size)
      end
    end

    shared_examples :keep_dialpeer_next_rate do
      let!(:next_rates) do
        [
          FactoryBot.create(:dialpeer_next_rate, dialpeer: to_delete_dialpeers.first),
          FactoryBot.create(:dialpeer_next_rate, dialpeer: to_delete_dialpeers.second)
        ]
      end

      it 'should keep next rates' do
        expect { subject }.not_to change(DialpeerNextRate, :count)
      end
    end

    context 'when pricelist items valid_from <= now()' do
      let(:valid_from) { 1.minute.ago.utc }

      context 'when dialpeers valid_from < now()' do
        let(:dialpeer_valid_from) { 1.second.ago.utc }

        include_examples :should_delete_dialpeers
        include_examples :performs_apply_changes_successfully
        include_examples :updates_to_delete_items
        it_behaves_like :remove_dialpeer_next_rate
      end

      context 'when dialpeers valid_from > now()' do
        let(:dialpeer_valid_from) { 1.day.from_now.utc }

        include_examples :should_delete_dialpeers
        include_examples :performs_apply_changes_successfully
        include_examples :updates_to_delete_items
        it_behaves_like :remove_dialpeer_next_rate
      end
    end

    context 'when pricelist items valid_from > now()' do
      let(:valid_from) { 2.days.from_now.beginning_of_day }

      context 'when dialpeers valid_from < now()' do
        let(:dialpeer_valid_from) { 1.second.ago.utc }

        include_examples :should_update_dialpeers
        include_examples :performs_apply_changes_successfully
        include_examples :updates_to_delete_items
        it_behaves_like :keep_dialpeer_next_rate
      end

      context 'when dialpeers valid_from > now() and < pricelist.valid_from' do
        let(:dialpeer_valid_from) { valid_from - 1.second }

        include_examples :should_update_dialpeers
        include_examples :performs_apply_changes_successfully
        include_examples :updates_to_delete_items
        it_behaves_like :keep_dialpeer_next_rate
      end

      context 'when dialpeers valid_from > pricelist.valid_from' do
        let(:dialpeer_valid_from) { valid_from + 1.second }

        include_examples :should_delete_dialpeers
        include_examples :performs_apply_changes_successfully
        include_examples :updates_to_delete_items
        it_behaves_like :remove_dialpeer_next_rate
      end
    end
  end

  context 'change dialpeers' do
    let!(:to_change_all_items) do
      [
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist,
                                                                                prefix: to_change_all_dialpeers.first.prefix,
                                                                                routing_tag_ids: to_change_all_dialpeers.first.routing_tag_ids,
                                                                                dialpeer: to_change_all_dialpeers.first,
                                                                                detected_dialpeer_ids: [to_change_all_dialpeers.first.id],
                                                                                enabled: false,
                                                                                initial_rate: 6,
                                                                                next_rate: 7,
                                                                                next_interval: 8,
                                                                                initial_interval: 9,
                                                                                connect_fee: 1.5),
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist,
                                                                                prefix: to_change_all_dialpeers.second.prefix,
                                                                                routing_tag_ids: to_change_all_dialpeers.second.routing_tag_ids,
                                                                                dialpeer: to_change_all_dialpeers.second,
                                                                                detected_dialpeer_ids: [to_change_all_dialpeers.second.id],
                                                                                enabled: false,
                                                                                initial_rate: 1,
                                                                                next_rate: 2,
                                                                                next_interval: 3,
                                                                                initial_interval: 4,
                                                                                connect_fee: 1.6,
                                                                                gateway_group: to_change_all_dialpeers.second.gateway_group,
                                                                                gateway: nil)
      ]
    end
    let!(:to_change_only_rates_items) do
      [
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist,
                                                                                prefix: to_change_only_rates_dialpeers.first.prefix,
                                                                                routing_tag_ids: to_change_only_rates_dialpeers.first.routing_tag_ids,
                                                                                dialpeer: to_change_only_rates_dialpeers.first,
                                                                                detected_dialpeer_ids: [to_change_only_rates_dialpeers.first.id],
                                                                                initial_rate: 1,
                                                                                next_rate: 2,
                                                                                next_interval: 3,
                                                                                initial_interval: 4,
                                                                                connect_fee: 1.6,
                                                                                enabled: to_change_only_rates_dialpeers.first.enabled,
                                                                                src_rewrite_rule: to_change_only_rates_dialpeers.first.src_rewrite_rule,
                                                                                dst_rewrite_rule: to_change_only_rates_dialpeers.first.dst_rewrite_rule,
                                                                                acd_limit: to_change_only_rates_dialpeers.first.acd_limit,
                                                                                asr_limit: to_change_only_rates_dialpeers.first.asr_limit,
                                                                                gateway_id: to_change_only_rates_dialpeers.first.gateway_id,
                                                                                src_rewrite_result: to_change_only_rates_dialpeers.first.src_rewrite_result,
                                                                                dst_rewrite_result: to_change_only_rates_dialpeers.first.dst_rewrite_result,
                                                                                priority: to_change_only_rates_dialpeers.first.priority,
                                                                                capacity: to_change_only_rates_dialpeers.first.capacity,
                                                                                lcr_rate_multiplier: to_change_only_rates_dialpeers.first.lcr_rate_multiplier,
                                                                                gateway_group_id: to_change_only_rates_dialpeers.first.gateway_group_id,
                                                                                force_hit_rate: to_change_only_rates_dialpeers.first.force_hit_rate,
                                                                                short_calls_limit: to_change_only_rates_dialpeers.first.short_calls_limit,
                                                                                src_name_rewrite_rule: to_change_only_rates_dialpeers.first.src_name_rewrite_rule,
                                                                                src_name_rewrite_result: to_change_only_rates_dialpeers.first.src_name_rewrite_result,
                                                                                exclusive_route: to_change_only_rates_dialpeers.first.exclusive_route,
                                                                                dst_number_min_length: to_change_only_rates_dialpeers.first.dst_number_min_length,
                                                                                dst_number_max_length: to_change_only_rates_dialpeers.first.dst_number_max_length,
                                                                                reverse_billing: to_change_only_rates_dialpeers.first.reverse_billing),
        FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist,
                                                                                prefix: to_change_only_rates_dialpeers.second.prefix,
                                                                                routing_tag_ids: to_change_only_rates_dialpeers.second.routing_tag_ids,
                                                                                dialpeer: to_change_only_rates_dialpeers.second,
                                                                                detected_dialpeer_ids: [to_change_only_rates_dialpeers.second.id],
                                                                                initial_rate: 1,
                                                                                next_rate: 2,
                                                                                next_interval: 3,
                                                                                initial_interval: 4,
                                                                                connect_fee: 1.6,
                                                                                enabled: to_change_only_rates_dialpeers.second.enabled,
                                                                                src_rewrite_rule: to_change_only_rates_dialpeers.second.src_rewrite_rule,
                                                                                dst_rewrite_rule: to_change_only_rates_dialpeers.second.dst_rewrite_rule,
                                                                                acd_limit: to_change_only_rates_dialpeers.second.acd_limit,
                                                                                asr_limit: to_change_only_rates_dialpeers.second.asr_limit,
                                                                                gateway_id: to_change_only_rates_dialpeers.second.gateway_id,
                                                                                src_rewrite_result: to_change_only_rates_dialpeers.second.src_rewrite_result,
                                                                                dst_rewrite_result: to_change_only_rates_dialpeers.second.dst_rewrite_result,
                                                                                priority: to_change_only_rates_dialpeers.second.priority,
                                                                                capacity: to_change_only_rates_dialpeers.second.capacity,
                                                                                lcr_rate_multiplier: to_change_only_rates_dialpeers.second.lcr_rate_multiplier,
                                                                                gateway_group_id: to_change_only_rates_dialpeers.second.gateway_group_id,
                                                                                force_hit_rate: to_change_only_rates_dialpeers.second.force_hit_rate,
                                                                                short_calls_limit: to_change_only_rates_dialpeers.second.short_calls_limit,
                                                                                src_name_rewrite_rule: to_change_only_rates_dialpeers.second.src_name_rewrite_rule,
                                                                                src_name_rewrite_result: to_change_only_rates_dialpeers.second.src_name_rewrite_result,
                                                                                exclusive_route: to_change_only_rates_dialpeers.second.exclusive_route,
                                                                                dst_number_min_length: to_change_only_rates_dialpeers.second.dst_number_min_length,
                                                                                dst_number_max_length: to_change_only_rates_dialpeers.second.dst_number_max_length,
                                                                                reverse_billing: to_change_only_rates_dialpeers.second.reverse_billing)
      ]
    end
    let!(:to_change_all_dialpeers) do
      [
        FactoryBot.create(:dialpeer, prefix: '123', vendor: project.vendor, account: project.account, routeset_discriminator: project.routeset_discriminator, routing_group: project.routing_group, valid_from: dialpeer_valid_from),
        FactoryBot.create(:dialpeer, prefix: '124', vendor: project.vendor, account: project.account, routeset_discriminator: project.routeset_discriminator, routing_group: project.routing_group, gateway: nil, valid_from: dialpeer_valid_from)
      ]
    end
    let!(:to_change_only_rates_dialpeers) do
      [
        FactoryBot.create(:dialpeer, prefix: '125', vendor: project.vendor, account: project.account, routeset_discriminator: project.routeset_discriminator, routing_group: project.routing_group, valid_from: dialpeer_valid_from),
        FactoryBot.create(:dialpeer, prefix: '126', vendor: project.vendor, account: project.account, routeset_discriminator: project.routeset_discriminator, routing_group: project.routing_group, valid_from: dialpeer_valid_from)
      ]
    end

    shared_examples :should_create_new_dialpeer_next_rates do
      it 'should create new dialpeer_next_rates' do
        expect { subject }.to change(DialpeerNextRate, :count).by(to_change_only_rates_items.size)

        next_rates = DialpeerNextRate.last(2)
        next_rates.each_with_index do |next_rate, index|
          item = to_change_only_rates_items[index].reload
          expect(next_rate).to have_attributes(
                                 dialpeer_id: item.detected_dialpeer_ids.first,
                                 next_rate: item.next_rate,
                                 initial_interval: item.initial_interval,
                                 next_interval: item.next_interval,
                                 connect_fee: item.connect_fee,
                                 apply_time: item.valid_from,
                                 external_id: nil,
                                 initial_rate: item.initial_rate,
                                 created_at: be_within(5.seconds).of(Time.now.utc)
                               )
        end
      end

      it 'should update valid till for actual dialpeer' do
        subject
        to_change_only_rates_dialpeers.each_with_index do |dialpeer, index|
          item = to_change_only_rates_items[index].reload
          expect(dialpeer.reload.valid_till).to eq(item.valid_till)
        end
      end
    end

    shared_examples :should_create_new_dialpeers do
      it 'should create new dialpeers' do
        expect { subject }.to change(Dialpeer, :count).by(to_change_all_items.size)

        to_change_all_items.each(&:reload)

        to_change_all_dialpeers.each_with_index do |dialpeer, index|
          expect(dialpeer.reload.valid_till).to eq(to_change_all_items[index].valid_from)
        end

        new_dialpeers = Dialpeer.last(2)
        new_dialpeers.each_with_index do |dialpeer, index|
          item = to_change_all_items[index]
          old_dialpeer = to_change_all_dialpeers[index]
          expect(dialpeer).to have_attributes(
                                enabled: item.enabled,
                                prefix: item.prefix,
                                src_rewrite_rule: item.src_rewrite_rule,
                                dst_rewrite_rule: item.dst_rewrite_rule,
                                acd_limit: item.acd_limit,
                                asr_limit: item.asr_limit,
                                gateway_id: item.gateway_id,
                                routing_group_id: item.routing_group_id,
                                next_rate: item.next_rate,
                                connect_fee: item.connect_fee,
                                vendor_id: item.vendor_id,
                                account_id: item.account_id,
                                src_rewrite_result: item.src_rewrite_result,
                                dst_rewrite_result: item.dst_rewrite_result,
                                priority: item.priority,
                                capacity: item.capacity,
                                lcr_rate_multiplier: item.lcr_rate_multiplier,
                                initial_rate: item.initial_rate,
                                initial_interval: item.initial_interval,
                                next_interval: item.next_interval,
                                valid_from: item.valid_from,
                                valid_till: item.valid_till,
                                gateway_group_id: item.gateway_group_id,
                                force_hit_rate: item.force_hit_rate,
                                short_calls_limit: item.short_calls_limit,
                                src_name_rewrite_rule: item.src_name_rewrite_rule,
                                src_name_rewrite_result: item.src_name_rewrite_result,
                                exclusive_route: item.exclusive_route,
                                dst_number_min_length: item.dst_number_min_length,
                                dst_number_max_length: item.dst_number_max_length,
                                reverse_billing: item.reverse_billing,
                                routing_tag_ids: item.routing_tag_ids,
                                routing_tag_mode_id: item.routing_tag_mode_id,
                                routeset_discriminator_id: item.routeset_discriminator_id,
                                network_prefix: old_dialpeer.network_prefix
                              )
        end
      end
    end

    shared_examples :should_update_dialpeers do
      it 'should be update dialpeers' do
        subject

        to_change_items = to_change_all_items.each(&:reload) + to_change_only_rates_items.each(&:reload)
        to_change_dialpeers = to_change_all_dialpeers + to_change_only_rates_dialpeers
        to_change_dialpeers.each_with_index do |dialpeer, index|
          expect(dialpeer.reload).to have_attributes(
                                       prefix: to_change_items[index].prefix,
                                       routing_tag_ids: to_change_items[index].routing_tag_ids,
                                       enabled: to_change_items[index].enabled,
                                       initial_rate: to_change_items[index].initial_rate,
                                       next_rate: to_change_items[index].next_rate,
                                       next_interval: to_change_items[index].next_interval,
                                       initial_interval: to_change_items[index].initial_interval,
                                       connect_fee: to_change_items[index].connect_fee,
                                       valid_from: be_within(5.seconds).of(Time.now.utc),
                                       valid_till: pricelist.valid_till
                                     )
        end
      end
    end

    shared_examples :updates_to_change_items do
      it 'clears dialpeer_id for to_change items' do
        subject
        to_change_items = to_change_all_items + to_change_only_rates_items
        to_change_dialpeers = to_change_all_dialpeers + to_change_only_rates_dialpeers
        to_change_items.each_with_index do |item, index|
          expect(item.reload).to have_attributes(
                                   dialpeer_id: nil,
                                   detected_dialpeer_ids: [to_change_dialpeers[index].id],
                                   valid_from: be_present
                                 )
        end
      end
    end

    shared_examples :should_change_type_to_create do
      it 'should create new dialpeers' do
        expect { subject }.not_to change(Dialpeer, :count)
        all_dialpeers = to_change_all_dialpeers + to_change_only_rates_dialpeers
        all_items = to_change_all_items + to_change_only_rates_items

        all_dialpeers.each do |dialpeer|
          expect(Dialpeer).not_to be_exists(dialpeer.id)
        end

        new_dialpeers = Dialpeer.last(all_items.size)
        new_dialpeers.each_with_index do |dialpeer, index|
          old_dialpeer = all_dialpeers[index]
          item = all_items[index].reload
          expect(dialpeer).to have_attributes(
                                enabled: item.enabled,
                                prefix: item.prefix,
                                src_rewrite_rule: item.src_rewrite_rule,
                                dst_rewrite_rule: item.dst_rewrite_rule,
                                acd_limit: item.acd_limit,
                                asr_limit: item.asr_limit,
                                gateway_id: item.gateway_id,
                                routing_group_id: item.routing_group_id,
                                next_rate: item.next_rate,
                                connect_fee: item.connect_fee,
                                vendor_id: item.vendor_id,
                                account_id: item.account_id,
                                src_rewrite_result: item.src_rewrite_result,
                                dst_rewrite_result: item.dst_rewrite_result,
                                priority: item.priority,
                                capacity: item.capacity,
                                lcr_rate_multiplier: item.lcr_rate_multiplier,
                                initial_rate: item.initial_rate,
                                initial_interval: item.initial_interval,
                                next_interval: item.next_interval,
                                valid_from: item.valid_from,
                                valid_till: item.valid_till,
                                gateway_group_id: item.gateway_group_id,
                                force_hit_rate: item.force_hit_rate,
                                short_calls_limit: item.short_calls_limit,
                                src_name_rewrite_rule: item.src_name_rewrite_rule,
                                src_name_rewrite_result: item.src_name_rewrite_result,
                                exclusive_route: item.exclusive_route,
                                dst_number_min_length: item.dst_number_min_length,
                                dst_number_max_length: item.dst_number_max_length,
                                reverse_billing: item.reverse_billing,
                                routing_tag_ids: item.routing_tag_ids,
                                routing_tag_mode_id: item.routing_tag_mode_id,
                                routeset_discriminator_id: item.routeset_discriminator_id,
                                network_prefix: old_dialpeer.network_prefix
                              )
        end
      end

      it 'should change items type' do
        subject

        all_items = to_change_all_items + to_change_only_rates_items
        all_items.each do |item|
          expect(item.reload).to have_attributes(
                                   type: RateManagement::PricelistItem::CONST::TYPE_CREATE,
                                   dialpeer_id: nil,
                                   detected_dialpeer_ids: []
                                 )
        end
      end
    end

    shared_examples :remove_dialpeer_next_rate do
      let!(:next_rates) do
        [
          FactoryBot.create(:dialpeer_next_rate, dialpeer: to_change_all_dialpeers.first),
          FactoryBot.create(:dialpeer_next_rate, dialpeer: to_change_only_rates_dialpeers.first)
        ]
      end

      it 'should remove next rates' do
        expect { subject }.to change(DialpeerNextRate, :count).by(-next_rates.size)
      end
    end

    context 'when pricelist items valid_from <= now()' do
      let(:valid_from) { 1.day.ago.utc }

      context 'when dialpeers valid_from < items valid_from' do
        let(:dialpeer_valid_from) { 2.days.ago.utc }

        include_examples :should_create_new_dialpeers
        include_examples :should_create_new_dialpeer_next_rates
        include_examples :performs_apply_changes_successfully
        include_examples :updates_to_change_items

        context 'when changed only valid_till' do
          before do
            to_change_only_rates_items.each_with_index do |item, index|
              item.update!(
                initial_rate: to_change_only_rates_dialpeers[index].initial_rate,
                next_rate: to_change_only_rates_dialpeers[index].next_rate,
                next_interval: to_change_only_rates_dialpeers[index].next_interval,
                initial_interval: to_change_only_rates_dialpeers[index].initial_interval,
                connect_fee: to_change_only_rates_dialpeers[index].connect_fee,
                valid_till: to_change_only_rates_dialpeers[index].valid_till + 1.day
              )
            end
          end

          it 'should not create new dialpeer next rates' do
            expect { subject }.not_to change(DialpeerNextRate, :count)
          end

          it 'should update valid till for actual dialpeer' do
            subject
            to_change_only_rates_dialpeers.each_with_index do |dialpeer, index|
              item = to_change_only_rates_items[index].reload
              expect(dialpeer.reload.valid_till).to eq(item.valid_till)
            end
          end
        end
      end

      context 'when dialpeers valid_from > items valid_from' do
        let(:dialpeer_valid_from) { 1.day.from_now.utc }

        include_examples :should_change_type_to_create
        include_examples :performs_apply_changes_successfully
        it_behaves_like :remove_dialpeer_next_rate
      end
    end

    context 'when pricelist items valid_from > now()' do
      let(:valid_from) { 2.days.from_now.beginning_of_day }

      context 'when dialpeers valid_from < items valid_from ' do
        let(:dialpeer_valid_from) { 1.second.ago.utc }

        include_examples :should_create_new_dialpeers
        include_examples :should_create_new_dialpeer_next_rates
        include_examples :performs_apply_changes_successfully
        include_examples :updates_to_change_items

        context 'when changed only valid_till' do
          before do
            to_change_only_rates_items.each_with_index do |item, index|
              item.update!(
                initial_rate: to_change_only_rates_dialpeers[index].initial_rate,
                next_rate: to_change_only_rates_dialpeers[index].next_rate,
                next_interval: to_change_only_rates_dialpeers[index].next_interval,
                initial_interval: to_change_only_rates_dialpeers[index].initial_interval,
                connect_fee: to_change_only_rates_dialpeers[index].connect_fee,
                valid_till: to_change_only_rates_dialpeers[index].valid_till + 1.day
              )
            end
          end

          it 'should not create new dialpeer next rates' do
            expect { subject }.not_to change(DialpeerNextRate, :count)
          end

          it 'should update valid till for actual dialpeer' do
            subject
            to_change_only_rates_dialpeers.each_with_index do |dialpeer, index|
              item = to_change_only_rates_items[index].reload
              expect(dialpeer.reload.valid_till).to eq(item.valid_till)
            end
          end
        end
      end

      context 'when dialpeers valid_from > now() and < items valid_from' do
        let(:dialpeer_valid_from) { valid_from - 1.second }

        include_examples :should_create_new_dialpeers
        include_examples :should_create_new_dialpeer_next_rates
        include_examples :performs_apply_changes_successfully
        include_examples :updates_to_change_items

        context 'when changed only valid_till' do
          before do
            to_change_only_rates_items.each_with_index do |item, index|
              item.update!(
                initial_rate: to_change_only_rates_dialpeers[index].initial_rate,
                next_rate: to_change_only_rates_dialpeers[index].next_rate,
                next_interval: to_change_only_rates_dialpeers[index].next_interval,
                initial_interval: to_change_only_rates_dialpeers[index].initial_interval,
                connect_fee: to_change_only_rates_dialpeers[index].connect_fee,
                valid_till: to_change_only_rates_dialpeers[index].valid_till + 1.day
              )
            end
          end

          it 'should not create new dialpeer next rates' do
            expect { subject }.not_to change(DialpeerNextRate, :count)
          end

          it 'should update valid till for actual dialpeer' do
            subject
            to_change_only_rates_dialpeers.each_with_index do |dialpeer, index|
              item = to_change_only_rates_items[index].reload
              expect(dialpeer.reload.valid_till).to eq(item.valid_till)
            end
          end
        end
      end

      context 'when dialpeers valid_from > items valid_from' do
        let(:dialpeer_valid_from) { valid_from + 1.second }

        include_examples :should_change_type_to_create
        include_examples :performs_apply_changes_successfully
        it_behaves_like :remove_dialpeer_next_rate
      end

      context 'when dialpeers valid_from = items valid_from' do
        let(:dialpeer_valid_from) { valid_from }

        include_examples :should_change_type_to_create
        include_examples :performs_apply_changes_successfully
        it_behaves_like :remove_dialpeer_next_rate
      end
    end
  end

  context 'when pricelist is new state' do
    let(:state) { :new }

    include_examples :apply_changes_failed, 'Pricelist must be in dialpeers detected state'
  end

  context 'when pricelist is applied state' do
    let(:state) { :applied }

    include_examples :apply_changes_failed, 'Pricelist must be in dialpeers detected state'
  end

  context 'when pricelist has error items' do
    let!(:with_error_item) do
      FactoryBot.create(:rate_management_pricelist_item, :filed_from_project, pricelist: pricelist, detected_dialpeer_ids: [1, 2])
    end

    include_examples :apply_changes_failed, 'Pricelist must be without error items'
  end

  context 'when pricelist.valid_till is in the past' do
    let(:valid_from) { 2.days.from_now }
    let(:valid_till) { 1.second.ago }

    include_examples :apply_changes_failed, 'Pricelist valid_till must be in the future'
  end
end

# frozen_string_literal: true

require_relative Rails.root.join('lib/prometheus/cdr_compaction_hook_processor')

RSpec.describe Jobs::CdrCompaction, '#call' do
  subject do
    job.call
  end

  let(:job) { described_class.new(double) }
  let(:cdr_compaction_delay) { 14 }
  let(:cdr_compaction_hook) { nil }
  let(:cdr_compaction_queries) do
    [
      'DELETE FROM %<table>s where duration = 0 and routing_attempt > 0',
      'UPDATE %<table>s SET lega_user_agent = NULL, legb_user_agent = NULL'
    ]
  end
  let(:prometheus_enabled) { false }

  before do
    allow(job).to receive(:cdr_compaction_delay).and_return(cdr_compaction_delay)
    allow(job).to receive(:cdr_compaction_hook).and_return(cdr_compaction_hook)
    allow(job).to receive(:cdr_compaction_queries).and_return(cdr_compaction_queries)

    allow(PrometheusConfig).to receive(:enabled?).and_return(prometheus_enabled)

    PartitionModel::Cdr.to_a.each(&:destroy!)
  end

  shared_examples :should_not_collect_prometheus_metrics do
    it 'should NOT collect Prometheus metrics' do
      expect(CdrCompactionHookProcessor).to_not receive(:collect)
      subject
    end
  end

  context 'when there are old Cdr::Cdr partitions' do
    before do
      Cdr::Cdr.add_partition_for Time.current
      Cdr::Cdr.add_partition_for 1.day.from_now
      Cdr::Cdr.add_partition_for 1.day.ago
      Cdr::Cdr.add_partition_for 2.days.ago
      Cdr::Cdr.add_partition_for 3.days.ago
      Cdr::Cdr.add_partition_for 4.days.ago
      Cdr::Cdr.add_partition_for 5.days.ago
    end

    let!(:not_affected_cdrs) do
      [
        FactoryBot.create(:cdr, time_start: 1.day.ago.beginning_of_day, duration: 0, routing_attempt: 1),
        FactoryBot.create(:cdr, time_start: 2.days.ago.beginning_of_day, duration: 0, routing_attempt: 1),
        FactoryBot.create(:cdr, time_start: 3.days.ago.beginning_of_day, duration: 0, routing_attempt: 1),
        FactoryBot.create(:cdr, time_start: 4.days.ago.beginning_of_day, lega_user_agent: 'a', legb_user_agent: 'b'),
        FactoryBot.create(:cdr, time_start: 5.days.ago.beginning_of_day, lega_user_agent: 'a', legb_user_agent: 'b')
      ]
    end

    let(:old_partition_time) { cdr_compaction_delay.days.ago.beginning_of_day }
    let(:old_partition_name) { "cdr.cdr_#{(old_partition_time - 1.day).strftime('%Y_%m_%d')}" }
    let!(:old_partition) { Cdr::Cdr.add_partition_for(old_partition_time) }
    let!(:old_cdrs_for_delete) { FactoryBot.create_list(:cdr, 3, duration: 0, routing_attempt: 1, time_start: old_partition_time - 1.day) }
    let!(:old_cdrs_for_update) { FactoryBot.create_list(:cdr, 3, lega_user_agent: 'a', legb_user_agent: 'b', time_start: old_partition_time - 1.day) }

    shared_examples :should_compact_successfully do
      it 'should manage old cdrs' do
        expect { subject }.to change { Cdr::Cdr.count }.by(-old_cdrs_for_delete.size)

        old_cdrs_for_delete.each do |cdr|
          expect(Cdr::Cdr).not_to exist(cdr.id)
        end

        old_cdrs_for_update.each do |cdr|
          expect(cdr.reload).to have_attributes(lega_user_agent: nil, legb_user_agent: nil)
        end
      end

      it 'should not affect not affected cdrs' do
        not_affected_cdr_ids = not_affected_cdrs.pluck(:id)
        expect { subject }.not_to change {
          Cdr::Cdr.where(id: not_affected_cdr_ids).to_a.pluck(:attributes)
        }
      end

      it 'should save compacted table record' do
        expect { subject }.to change { Cdr::CdrCompactedTable.count }.by(1)

        expect(Cdr::CdrCompactedTable.last).to have_attributes(
          table_name: old_partition_name
        )
      end
    end

    include_examples :should_compact_successfully
    include_examples :should_not_collect_prometheus_metrics

    context 'when Prometheus is enabled' do
      let(:prometheus_enabled) { true }

      include_examples :should_compact_successfully
      include_examples :should_not_collect_prometheus_metrics
    end

    context 'when compaction hook is set' do
      let(:cdr_compaction_hook) { 'echo' }

      include_examples :should_compact_successfully
      include_examples :should_not_collect_prometheus_metrics

      context 'when Prometheus is enabled' do
        let(:prometheus_enabled) { true }

        context 'when hook successful' do
          include_examples :should_compact_successfully

          it 'should collect Prometheus metrics' do
            expect(CdrCompactionHookProcessor).to receive(:collect).with(executions: 1)
            expect(CdrCompactionHookProcessor).to receive(:collect).with(duration: be_present)
            expect(CdrCompactionHookProcessor).not_to receive(:collect).with(errors: anything)
            subject
          end
        end

        context 'when hook unsuccessful' do
          let(:cdr_compaction_hook) { 'false' }

          it 'should not manage old cdrs' do
            expect { subject }.not_to change { Cdr::Cdr.count }

            old_cdrs_for_delete.each do |cdr|
              expect(Cdr::Cdr).to exist(cdr.id)
            end

            old_cdrs_for_update.each do |cdr|
              expect(cdr.reload).to have_attributes(lega_user_agent: 'a', legb_user_agent: 'b')
            end
          end

          it 'should not affect not affected cdrs' do
            not_affected_cdr_ids = not_affected_cdrs.pluck(:id)
            expect { subject }.not_to change {
              Cdr::Cdr.where(id: not_affected_cdr_ids).to_a.pluck(:attributes)
            }
          end

          it 'should collect Prometheus metrics' do
            expect(CdrCompactionHookProcessor).to receive(:collect).with(executions: 1)
            expect(CdrCompactionHookProcessor).to receive(:collect).with(duration: be_present)
            expect(CdrCompactionHookProcessor).to receive(:collect).with(errors: 1)

            subject
          end
        end
      end
    end

    context 'when partition already compacted' do
      before do
        FactoryBot.create(:cdr_compacted_table, table_name: old_partition_name)
      end

      it 'should not affect any cdrs' do
        expect { subject }.not_to change {
          [Cdr::Cdr.count, Cdr::Cdr.all.to_a.pluck(:attributes)]
        }
      end

      it 'should not save compacted table record' do
        expect { subject }.not_to change { Cdr::CdrCompactedTable.count }
      end

      include_examples :should_not_collect_prometheus_metrics
    end

    context 'when compaction disabled' do
      let(:old_partition_time) { 2.days.ago.beginning_of_day }
      let(:cdr_compaction_delay) { nil }

      it 'should not affect any cdrs' do
        expect { subject }.not_to change {
          [Cdr::Cdr.count, Cdr::Cdr.all.to_a.pluck(:attributes)]
        }
      end

      it 'should not save compacted table record' do
        expect { subject }.not_to change { Cdr::CdrCompactedTable.count }
      end
    end

    context 'when compaction queries empty' do
      let(:cdr_compaction_queries) { [] }

      it 'should not affect any cdrs' do
        expect { subject }.not_to change {
          [Cdr::Cdr.count, Cdr::Cdr.all.to_a.pluck(:attributes)]
        }
      end

      it 'should save compacted table record' do
        expect { subject }.to change { Cdr::CdrCompactedTable.count }.by(1)

        expect(Cdr::CdrCompactedTable.last).to have_attributes(
                                                 table_name: old_partition_name
                                               )
      end
    end
  end

  context 'when there are no old Cdr::Cdr partitions' do
    before do
      Cdr::Cdr.add_partition_for Time.current
      Cdr::Cdr.add_partition_for 1.day.from_now
      Cdr::Cdr.add_partition_for 1.day.ago
      Cdr::Cdr.add_partition_for 2.days.ago
      Cdr::Cdr.add_partition_for 3.days.ago
      Cdr::Cdr.add_partition_for 4.days.ago
      Cdr::Cdr.add_partition_for 5.days.ago

      FactoryBot.create(:cdr, time_start: 1.day.ago.beginning_of_day, duration: 0, routing_attempt: 1)
      FactoryBot.create(:cdr, time_start: 2.days.ago.beginning_of_day, duration: 0, routing_attempt: 1)
      FactoryBot.create(:cdr, time_start: 3.days.ago.beginning_of_day, duration: 0, routing_attempt: 1)
      FactoryBot.create(:cdr, time_start: 4.days.ago.beginning_of_day, lega_user_agent: 'a', legb_user_agent: 'b')
      FactoryBot.create(:cdr, time_start: 5.days.ago.beginning_of_day, lega_user_agent: 'a', legb_user_agent: 'b')
    end

    it 'should not affect any cdrs' do
      expect { subject }.not_to change {
        [Cdr::Cdr.count, Cdr::Cdr.all.to_a.pluck(:attributes)]
      }
    end

    it 'should not save compacted table record' do
      expect { subject }.not_to change { Cdr::CdrCompactedTable.count }
    end
  end
end

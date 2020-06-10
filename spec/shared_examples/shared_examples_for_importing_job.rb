# frozen_string_literal: true

RSpec.shared_examples 'Jobs for importing data' do
  context 'on create job' do
    it 'creates proper jobs in queue' do
      expect { preview_class.run_in_background(paper_trail_info) }.to change { Delayed::Job.where(queue: queue_label).count }.by(jobs_count)
    end
  end

  context 'on job complete successfully' do
    it 'moves importing data to real table' do
      expect { run_jobs }.to change { import_class.count }.by(importing_items_count)
    end

    it 'writes jobs status to log' do
      # we have 1-Start and 1-Finish => 2 * jobs_count
      expect { run_jobs }.to change { LogicLog.count }.by(jobs_count * 2)
    end

    it 'creates paper_tail for imported data' do
      if import_class.respond_to?(:paper_trail)
        expect { run_jobs }.to change { PaperTrail::Version.where(item_type: import_class.to_s).count }.by(importing_items_count)
      else
        expect { run_jobs }.not_to change { PaperTrail::Version.where(item_type: import_class.to_s).count }
      end
    end

    # Array.wrap(v).join(', ') is needed for column with type "varchar[]"
    # In importing table they are plain varchar devided by comma
    # Array.wrap(v).join(', ') makes such fields identical in real and importing records
    it 'imported item has the same import_attributes values as preview item' do
      columns = preview_class.import_attributes.join(',')
      preview_attr = preview_class.select(columns).last.as_json.transform_values { |v| Array.wrap(v).join(', ') }
      expect { run_jobs }.to change {
                               real_attr = import_class.select(columns).last
                               if real_attr
                                 real_attr = real_attr.as_json.transform_values { |v| Array.wrap(v).join(', ') }
                               end
                               preview_attr == real_attr
                             }.from(false).to(true)
    end
  end

  context 'when empty o_id' do
    context 'scope for_update' do
      let(:action) { :for_update }
      it 'not creates real items ' do
        expect { run_jobs }.not_to change { import_class.count }
      end
      it 'not deletes preview items' do
        expect { run_jobs }.not_to change { preview_class.count }
      end
    end

    context 'scope for_create' do
      let(:action) { :for_create }
      it 'creates real items ' do
        expect { run_jobs }.to change { import_class.count }
      end
      it 'deletes preview items' do
        expect { run_jobs }.to change { preview_class.count }
      end
    end

    context 'without scope' do
      let(:action) { nil }
      it 'creates real items' do
        expect { run_jobs }.to change { import_class.count }
      end
      it 'deletes preview items' do
        expect { run_jobs }.to change { preview_class.count }
      end
    end
  end
end

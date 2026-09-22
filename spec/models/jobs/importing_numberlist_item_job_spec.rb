# frozen_string_literal: true

require 'shared_examples/shared_examples_for_importing_job'

RSpec.describe 'Importing::NumberlistItem => NumberlistItem delayed_job' do
  it_behaves_like 'Jobs for importing data' do
    include_context :init_importing_delayed_job do
      include_context :init_importing_numberlist_item
      let(:preview_class) { Importing::NumberlistItem }
    end
  end

  context 'when import has duplicated keys' do
    include_context :init_importing_delayed_job

    let(:preview_class) { Importing::NumberlistItem }
    let(:numberlist) { create(:numberlist) }
    let(:keys) { (1..20).map { |n| "1000#{n}" } }

    before do
      (keys + keys.reverse).each do |key|
        create(:importing_numberlist_item, key: key, _numberlist: numberlist, is_changed: true)
      end
    end

    it 'processes rows with the same key in the same job' do
      keys_per_job = Array.new(jobs_count) do |job_number|
        preview_class.for_job(jobs_count, job_number).pluck(:key)
      end

      expect(keys_per_job.flatten).to match_array(keys + keys)
      keys_per_job.combination(2) do |job_keys, other_job_keys|
        expect(job_keys & other_job_keys).to be_empty
      end
    end

    it 'creates one item per key and marks duplicates as failed' do
      expect { run_jobs }.to change { import_class.where(numberlist_id: numberlist.id).count }.by(keys.size)

      expect(Delayed::Job.where(queue: queue_label).where.not(last_error: nil).count).to eq(0)
      expect(preview_class.pluck(:key)).to match_array(keys)
      expect(preview_class.pluck(:error_string)).to all(include('Key has already been taken'))
    end

    context 'when unique columns applied' do
      before { preview_class.resolve_object_id(preview_class.strict_unique_attributes) }

      shared_examples 'skips duplicates' do
        it 'imports only first row of each key', :aggregate_failures do
          expect { run_jobs }.to change { import_class.where(numberlist_id: numberlist.id).count }.by(keys.size)

          expect(preview_class.pluck(:key)).to match_array(keys)
          expect(preview_class.pluck(:error_string)).to all(start_with(Importing::Base::DUPLICATE_ERROR))
        end
      end

      include_examples 'skips duplicates'

      context 'with for_create action' do
        let(:action) { :for_create }

        include_examples 'skips duplicates'
      end
    end
  end
end

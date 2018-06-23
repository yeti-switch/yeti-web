RSpec.shared_context :init_importing_delayed_job do

  let(:import_class) { preview_class.import_class }
  let(:importing_items_count) { preview_class.count }

  let(:jobs_count) { GuiConfig.import_max_threads }
  let(:queue_label) { Importing::ImportingDelayedJob::QUEUE_NAME }

  let(:paper_trail_info) do
    { whodunnit: 1, controller_info: {ip: '127.0.0.1'} }
  end
  let(:action) { nil }

  let(:run_jobs) do
    options = { controller_info: paper_trail_info, action: action }
    Importing::ImportingDelayedJob.create_jobs(preview_class, options)
    Delayed::Worker.new.work_off
  end

end

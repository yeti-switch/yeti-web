# frozen_string_literal: true

class Api::Rest::System::JobsController < Api::RestController
  def run
    #    BaseJob.transaction do
    @job = BaseJob.launch!(params[:id])
    #    end
    #    @job.run!
    respond_with(@job)
  end

  def index
    respond_with BaseJob.all
  end

  def capture_tags
    super.merge job_class: params[:id]
  end

  protected

  def user_for_paper_trail
    @job&.type || 'Unknown Job'
  end
end

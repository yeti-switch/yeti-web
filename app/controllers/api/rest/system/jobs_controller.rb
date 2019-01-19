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

  protected

  def user_for_paper_trail
    @job.try!(:type) || 'Unknown Job'
  end
end

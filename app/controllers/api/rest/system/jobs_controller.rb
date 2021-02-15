# frozen_string_literal: true

class Api::Rest::System::JobsController < Api::RestController
  def run
    @job = BaseJob.launch!(params[:id])
    render json: @job, status: :no_content
  end

  def index
    render json: BaseJob.all
  end

  def capture_tags
    super.merge job_class: params[:id]
  end

  protected

  def user_for_paper_trail
    @job&.type || 'Unknown Job'
  end
end

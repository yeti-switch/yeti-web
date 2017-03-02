module Concerns::IndexMaxRecords
  extend ActiveSupport::Concern


  def fix_max_records

    if request.format == 'csv'
      @max_per_page  = GuiConfig.max_records
      params[:page] = 1

    end

  end


end




# frozen_string_literal: true

module ResourceDSL
  module WithDefaultParams
    # @param opts[:if] [Proc] - passes params into proc, block will be executed if proc returns true
    # @param opts[:flash_type] [Proc] - passes params into proc, block will be executed if proc returns true
    # yield in context of controller
    # @yieldreturn message that will be shown in flash.now
    def with_default_params(opts = {}, &block)
      if_proc = opts[:if] || proc { |q: nil, **_| q.blank? }
      flash_type = opts.fetch(:flash_type, :notice_message)
      before_action only: [:index] do
        if instance_exec(params.to_unsafe_h.deep_symbolize_keys, &if_proc)
          message = instance_exec(&block)
          flash.now[flash_type] = message if message.present?
        end
      end
    end

    def with_default_realtime_interval
      with_default_params if: proc { |q: nil, **_| q.blank? || q[:time_interval_eq].blank? } do
        params[:q] ||= {}
        params[:q][:time_interval_eq] = Report::Realtime::Base::DEFAULT_INTERVAL
        "Records for time interval #{Report::Realtime::Base::DEFAULT_INTERVAL} seconds are displayed by default"
      end
    end
  end
end

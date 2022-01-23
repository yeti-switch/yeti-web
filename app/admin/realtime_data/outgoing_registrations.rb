# frozen_string_literal: true

ActiveAdmin.register RealtimeData::OutgoingRegistration, as: 'Outgoing Registrations' do
  menu parent: 'Realtime Data', priority: 30,
       if: proc { authorized?(:index, RealtimeData::OutgoingRegistration) && Node.any? }

  actions :index

  config.batch_actions = false

  filter :node_id_eq,
         as: :select,
         collection: proc { Node.all.pluck(:name, :id) },
         label: 'Node',
         input_html: { class: 'chosen' }

  controller do
    def show
      show!
    rescue NodeApi::Error => e
      flash[:warning] = e.message
      redirect_to_back
    end

    def find_collection
      @search = OpenStruct.new(params[:q])
      return [] if (params.to_unsafe_h[:q] || {}).delete_if { |_, v| v.blank? }.blank? && GuiConfig.registrations_require_filter

      registrations = []

      begin
        searcher = Yeti::OutgoingRegistrations.new(Node.all, params.to_unsafe_h[:q])
        registrations = searcher.search(empty_on_error: true)
        registrations = Kaminari.paginate_array(registrations).page(1).per(registrations.count)
        flash.now[:warning] = searcher.errors if searcher.errors.any?
      rescue StandardError => e
        Rails.logger.error { "<#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
        CaptureError.capture(e, tags: { component: 'AdminUI' })
        flash.now[:warning] = e.message
      end
      @skip_drop_down_pagination = true
      registrations
    end
  end

  index blank_slate_content: lambda {
                               if GuiConfig.registrations_require_filter
                                 GuiConfig::FILTER_MISSED_TEXT
                               end
                             }, download_links: false do
    RealtimeData::OutgoingRegistration.human_attributes.each do |attr|
      column attr, sortable: false
    end
  end
end

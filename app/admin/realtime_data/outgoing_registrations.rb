ActiveAdmin.register RealtimeData::OutgoingRegistration, as: 'Outgoing Registrations' do
  menu parent: "Realtime Data", priority: 30, if: proc { Node.any? }

  actions :index

  config.batch_actions = false

  filter :node_id_eq,
         as: :select,
         collection: proc { Node.all.pluck(:name, :id) },
         label: 'Node',
         input_html: {class: 'chosen'}

  controller do

    def show
      begin
        show!
      rescue YetisNode::Error => e
        flash[:warning] = e.message
        redirect_to_back
      end
    end

    def find_collection
      @search = OpenStruct.new(params[:q])
      return [] if clean_search_params(params[:q]).blank?  and GuiConfig.registrations_require_filter
      registrations = []

      begin
        registrations = Yeti::OutgoingRegistrations.new(Node.all, params[:q]).search
        registrations = Kaminari.paginate_array(registrations).page(1).per(registrations.count)
      rescue StandardError => e
        flash.now[:warning] = e.message
      end
      @skip_drop_down_pagination = true
      registrations
    end

  end


  index blank_slate_content: -> {
        if GuiConfig.registrations_require_filter
          GuiConfig::FILTER_MISSED_TEXT
        else
          nil
        end
    }, download_links: false do
    RealtimeData::OutgoingRegistration.human_attributes.each do |attr|
      column attr, sortable: false
    end
  end


end

# frozen_string_literal: true

ActiveAdmin.register RealtimeData::IncomingRegistration, as: 'Incoming Registrations' do
  actions :index, :show
  config.batch_actions = false
  menu parent: 'Realtime Data', priority: 30, if: proc { authorized?(:index, RealtimeData::IncomingRegistration) && Node.any? }

  member_action :registrations_data, method: :get do
    result = Yeti::RpcCalls::IncomingRegistrations.call Node.all, auth_id: params[:id].to_i
    render json: { data: result.data, errors: result.errors }
  end

  controller do
    def find_resource
      RealtimeData::IncomingRegistration.new(auth_id: params[:id].to_i)
    end

    def find_collection
      @search = OpenStruct.new(params.to_unsafe_h[:q]&.symbolize_keys || {})
      registrations = []

      begin
        @search.to_h.assert_valid_keys(:auth_id_eq)
        result = Yeti::RpcCalls::IncomingRegistrations.call Node.all, auth_id: @search.auth_id_eq

        registrations = result.data.map { |row| RealtimeData::IncomingRegistration.new(row) }
        RealtimeData::IncomingRegistration.load_associations(registrations, :gateway)
        registrations = Kaminari.paginate_array(registrations).page(1).per(registrations.count)
        flash.now[:warning] = result.errors if result.errors.any?
      rescue StandardError => e
        logger.error { "<#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
        CaptureError.capture(e, tags: { component: 'AdminUI' })
        flash.now[:error] = e.message
      end

      @skip_drop_down_pagination = true
      registrations
    end
  end

  filter :auth_id_eq,
         as: :select,
         collection: proc { Gateway.all },
         label: 'Gateway',
         input_html: { class: 'tom-select' }

  index download_links: false do
    column :node
    column :gateway
    column :contact
    column :expires
    column :path
    column :user_agent
    column :actions do |registration|
      link_to 'View', incoming_registration_path(registration.id) if registration.id
    end
  end

  show do
    div 'data-ajax-load-url': registrations_data_incoming_registration_path(resource),
        class: 'ajax-load-content' do
      para 'Loading...'
    end
  end
end

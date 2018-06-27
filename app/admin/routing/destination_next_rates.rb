ActiveAdmin.register Routing::DestinationNextRate, as: 'Destination Next Rate' do
  acts_as_belongs_to :destination,
                     parent_class: Routing::Destination,
                     collection_name: :destination_next_rates,
                     route_name: :destination_next_rates,
                     optional: true
  menu false
  actions :index, :new, :create, :edit, :update, :destroy
  config.batch_actions = false

  permit_params :initial_interval,
                :next_interval,
                :initial_rate,
                :next_rate,
                :connect_fee,
                :apply_time

  controller do
    def create
      super do |success,_|
        success.html { redirect_to destination_path(params[:destination_id], anchor: 'upcoming-price-changes') }
      end
    end

    def update
      super do |success,_|
        success.html { redirect_to destination_path(params[:destination_id], anchor: 'upcoming-price-changes') }
      end
    end
  end

  includes :destination

  action_item :destinations, only: [:index] do
    link_to "Destinations", destinations_path
  end

  sidebar :destination, priority: 1, only: [:new, :update], if: proc { assigns[:destination].present? } do

    attributes_table_for assigns[:destination] do
      row :id do
        auto_link(assigns[:destination], assigns[:destination].id)
      end
      row :initial_interval
      row :next_interval
      row :initial_rate
      row :next_rate
      row :connect_fee
      row :current_rate_id

    end
  end



  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :initial_interval
      f.input :next_interval
      f.input :initial_rate
      f.input :next_rate
      f.input :connect_fee
      f.input :apply_time, as: :date_time_picker,  datepicker_options: {defaultTime: '00:00'}
    end
    f.actions
  end



  filter :id_eq, label: 'ID'

  filter :applied, as: :select,
         input_html: {class: :chosen},
         collection: [['Yes', true], ['No', false]]

  filter :apply_time
  filter :initial_rate
  filter :next_rate
  filter :initial_interval
  filter :next_interval
  filter :connect_fee
  filter :created_at, as: :date_time_range
  filter :updated_at, as: :date_time_range
  filter :external_id



  index do
    column :id
    actions
    column :destination
    column :applied
    column :apply_time
    column :initial_rate
    column :next_rate
    column :initial_interval
    column :next_interval
    column :connect_fee
    column :created_at
    column :updated_at
    column :external_id
  end



end

# frozen_string_literal: true

ActiveAdmin.register DialpeerNextRate do
  belongs_to :dialpeer, parent_class: Dialpeer, optional: true
  menu false
  actions :index, :new, :create, :edit, :update, :destroy
  config.batch_actions = false

  controller do
    def permitted_params
      params.permit *active_admin_namespace.permitted_params, :dialpeer_id,
                    active_admin_config.param_key => %i[
                      initial_interval
                      next_interval
                      initial_rate
                      next_rate
                      connect_fee
                      apply_time
                    ]
    end

    def create
      super do |success, _|
        success.html { redirect_to dialpeer_path(params[:dialpeer_id], anchor: 'upcoming-price-changes') }
      end
    end

    def update
      super do |success, _|
        success.html { redirect_to dialpeer_path(params[:dialpeer_id], anchor: 'upcoming-price-changes') }
      end
    end
  end

  includes :dialpeer

  action_item :dialpeers, only: [:index] do
    link_to 'Dialpeers', dialpeers_path
  end

  sidebar :dialpeer, priority: 1, only: %i[new update], if: proc { assigns[:dialpeer].present? } do
    attributes_table_for assigns[:dialpeer] do
      row :id do
        auto_link(assigns[:dialpeer], assigns[:dialpeer].id)
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
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :initial_interval
      f.input :next_interval
      f.input :initial_rate
      f.input :next_rate
      f.input :connect_fee
      f.input :apply_time, as: :date_time_picker, datepicker_options: { defaultTime: '00:00' }
    end
    f.actions
  end

  filter :id_eq, label: 'ID'

  filter :applied, as: :select,
                   input_html: { class: :chosen },
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

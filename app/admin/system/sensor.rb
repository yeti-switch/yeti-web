ActiveAdmin.register System::Sensor do
  #actions :index, :show
  menu parent: "System", label: "Sensors", priority: 140
  config.batch_actions = false

  permit_params :name, :mode_id, :source_interface, :target_mac, :source_ip,
                :target_ip, :target_port, :hep_capture_id

  controller do
    def scoped_collection
      super.eager_load(:mode)
    end

    def destroy
      begin
        destroy!
      rescue ActiveRecord::ActiveRecordError => e
        flash[:error] = e.message
        redirect_to :back
      end
    end
  end

  # Temporary disable "use_routing"
  # Dima.s requested this 19.11.2014

  filter :id
  filter :mode
  filter :name

  index do
    id_column
    column :name
    column :mode
    column :source_interface
    column :target_mac
    # column :use_routing
    column :source_ip
    column :target_ip
    column :target_port
    column :hep_capture_id
  end

  show do |s|
    attributes_table do
      row :id
      row :name
      row :mode
      row :source_interface
      row :target_mac
      # row :use_routing
      row :source_ip
      row :target_ip
      row :target_port
      row :hep_capture_id
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :name
      f.input :mode
      f.input :source_interface, input_html: {'data-depend_selector' => '#system_sensor_mode_id', 'data-depend_value' => System::SensorMode::IP_ETHERNET}
      f.input :target_mac, as: :string, input_html: {'data-depend_selector' => '#system_sensor_mode_id', 'data-depend_value' => System::SensorMode::IP_ETHERNET}
      # f.input :use_routing
      f.input :source_ip, as: :string, input_html: {'data-depend_selector' => '#system_sensor_mode_id', 'data-depend_value' => System::SensorMode::IP_IP}
      f.input :target_ip, as: :string, input_html: {'data-depend_selector' => '#system_sensor_mode_id', 'data-depend_value' => System::SensorMode::IP_IP}
      f.input :target_ip, as: :string, input_html: {'data-depend_selector' => '#system_sensor_mode_id', 'data-depend_value' => System::SensorMode::HEPv3}
      f.input :target_port, input_html: {'data-depend_selector' => '#system_sensor_mode_id', 'data-depend_value' => System::SensorMode::HEPv3}
      f.input :hep_capture_id, input_html: {'data-depend_selector' => '#system_sensor_mode_id', 'data-depend_value' => System::SensorMode::HEPv3}
    end
    f.actions
  end


end

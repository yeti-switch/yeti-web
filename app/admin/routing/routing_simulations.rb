# frozen_string_literal: true

ActiveAdmin.register_page 'Routing simulation' do
  menu parent: 'Routing', priority: 999, label: 'Routing Simulation'

  content do
    begin
      @dc = Routing::Simulation.new(params[:routing_simulation])
      if !params[:routing_simulation].nil? && @dc.valid? # force object validation before form rendering
        @dc.save!
        Rails.logger.info @dc.errors
      end
    rescue Exception => e
      pre do
        e.message
      end
    end
    panel 'Call simulation' do
      render('routing_simulation/form', dc: @dc) # Calls a partial
    end

    if !params[:routing_simulation].nil? && @dc.valid? && !@dc.debug.nil?

      panel 'results' do
        table_for @dc.debug do
          column :disconnect_code do |r|
            auto_link(r.disconnect_code)
          end
          column :src_prefix_in
          column :dst_prefix_in
          column :customer_auth do |r|
            auto_link(r.customer_auth)
          end
          column :src_prefix_routing
          column :dst_prefix_routing
          column :lrn
          column :dst_country do |r|
            auto_link(r.dst_country)
          end
          column :dst_network do |r|
            auto_link(r.dst_network)
          end
          column :rateplan do |r|
            auto_link(r.rateplan)
          end
          column :destination do |r|
            auto_link(r.destination)
          end
          column :destination_initial_rate
          column :destination_next_rate
          column :dialpeer do |r|
            auto_link(r.dialpeer)
          end
          column :destination_initial_interval
          column :destination_next_interval
          column :destination_fee

          column :routing_plan do |r|
            auto_link(r.routing_plan)
          end

          column :routing_group do |r|
            auto_link(r.routing_group)
          end
          column :vendor do |r|
            auto_link(r.vendor)
          end

          column :dialpeer_initial_rate
          column :dialpeer_next_rate
          column :dialpeer_initial_interval
          column :dialpeer_next_interval
          column :dialpeer_fee
          column :termination_gateway do |r|
            auto_link(r.termination_gateway)
          end
          column :src_prefix_out
          column :dst_prefix_out
          column :time_limit
        end
      end

      panel 'log' do
        ul do
          @dc.notices.each do |notice|
            li do
              notice
            end
          end
        end
      end

    end
  end
end

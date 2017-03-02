ActiveAdmin.register_page "Debug Call" do
  menu parent: "Routing", priority: 999, label: "Call Simulation"

  content do
    begin
      @dc = DebugCall.new(params[:debug_call])
      @dc.save!

    rescue Exception => e
      pre do
        e.message
      end

    end
#    panel 'debug inputs' do
      tabs do
        tab :Simple do
          render("debug_call/debug_simple", {dc: @dc}) # Calls a partial
        end
        tab :Detailed do
          render("debug_call/debug", {dc: @dc}) # Calls a partial
        end
      end

 #   end
    if @dc.valid?

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
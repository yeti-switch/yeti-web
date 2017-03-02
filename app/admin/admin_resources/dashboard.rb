ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }
  content title: proc { I18n.t("active_admin.dashboard") } do # + "   (Calls online: #{ActiveCallsStat.current_total})" } do


    tabs  do
      tab 'Active Calls 24 hours' do
           render partial: 'charts/nodes' , locals: { path: 'nodes', href: 'active-calls-24-hours' }
      end
      tab 'Profitability' do
        render partial: 'charts/profit'
      end

      tab 'Calls Duration' do
             render partial: 'charts/duration'
           end

    end


    columns do
      column do
        panel "Last 10 pending events" + " (Total: #{Event.count})" do
          table_for(Event.eager_load(:node).order("created_at desc").limit(10)) do
            column :created_at
            column :command
            column :node
            column :retries
            column :last_error do |e|
              div class: :has_tooltip, title: e.last_error do
                e.last_error.to_s[0..20]
              end
            end
          end
        end if Event.any?

        panel "Billing provisioning" do
          attributes_table_for Cdr::Cdr.provisioning_info do
            row :new_events
            row :pending_events
          end
        end


      end


      column do


        panel "Replication" do
          if RsReplication.any?
            table_for(RsReplication.order('application_name')) do
              column :application_name
              column :client_addr
              column :backend_start
              column :state

            end
          else
            span do
              text_node "No replication"
            end
          end
        end

      end
    end
  end # content
end

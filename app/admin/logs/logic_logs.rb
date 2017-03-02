ActiveAdmin.register LogicLog do
  menu parent: "Logs", priority: 30, label: "Logic log"

  actions :index, :show
  config.batch_actions = false
  show do |log|
    attributes_table do

      row :id
      row :timestamp
      row :txid
      row :level
      row :source
      row :msg do
        pre do
          log.msg
        end
      end

    end
  end

  index do
    id_column
    column :timestamp
    column :txid
    column :level
    column :source
    column :msg do |row|

      if row.msg.present?
        if row.msg.length > 100
          div class: :has_tooltip, title: row.msg do
            row.msg[0...100] << "..."
          end
        else
          row.msg
        end

      end

    end

  end

  filter :id
  filter :timestamp
  filter :txid
  filter :level
  filter :source
  filter :msg

end

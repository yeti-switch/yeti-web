# frozen_string_literal: true

ActiveAdmin.register AuditLogItem do
  menu parent: 'Logs', priority: 10, label: 'Audit log'
  config.batch_actions = false
  actions :index, :show

  filter :id
  filter :created_at, as: :date_time_range
  filter :item_type, input_html: { class: 'tom-select' }
  filter :item_id_eq
  filter :event, as: :select, collection: [%w[create create], %w[destroy destroy], %w[update update]], input_html: { class: 'tom-select' }
  filter :whodunnit
  filter :ip
  filter :txid

  with_default_params do
    params[:q] = { created_at_gteq_datetime_picker: 0.days.ago.beginning_of_day } # only 1 last days by default
    'Only records from beginning of the day showed by default'
  end

  controller do
    def scoped_collection
      super.includes(:item)
    end
  end

  show do |version|
    attributes_table do
      row :id
      row :item_type
      row :item
      row :event
      row :whodunnit
      row :date do
        version.created_at
      end
      row :txid
      row :ip
    end

    reified_item = version.reify(dup: true)
    unless reified_item.nil?
      panel 'Values before event' do
        attributes_table_for reified_item do
          row :id
          reified_item.class.content_columns.each do |col|
            row col.name.to_sym
          end
        end
      end
    end

    if version.changeset.any?
      panel 'Changes' do
        attributes_table_for version.changeset do
          version.changeset.each_key do |key|
            next unless version.changeset[key].reject(&:blank?).any?

            row key do
              text_node version.changeset[key][0]
              text_node ' -> '
              text_node version.changeset[key][1]
            end
          end
        end
      end
    end
  end

  index do
    id_column
    column :item_type
    column 'Item', sortable: :item_id do |v|
      text = []
      text << v.item_id.to_s
      url = smart_url_for(v.item, version: v.id)
      if v.item.present? && v.item.respond_to?(:display_name) && url
        text << link_to(v.item.display_name, url)
      elsif v.item.present? && v.item.respond_to?(:display_name)
        text << v.item.display_name
      end
      raw text.join(' ')
    end

    column :event
    column :created_at
    column :txid
    column('Who Id', sortable: 'whodunnit', &:whodunnit)

    column('Who', sortable: 'whodunnit') do |version|
      whodunit_link(version.whodunnit)
    end

    column :ip
  end
end

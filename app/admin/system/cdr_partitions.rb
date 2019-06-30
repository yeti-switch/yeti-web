# frozen_string_literal: true

ActiveAdmin.register PartitionModel::Cdr, as: 'CDR Partition' do
  menu parent: 'System', label: 'CDR Partitions'

  actions :index, :show

  filter :parent_table_eq,
         as: :select,
         label: 'Parent Table',
         input_html: { class: :chosen },
         collection: PartitionModel::Cdr.partitioned_tables

  controller do
    def apply_sorting(chain)
      chain
    end

    def apply_filtering(chain)
      query_params = (params.to_unsafe_h[:q] || {}).delete_if { |_, v| v.blank? }
      @search = OpenStruct.new(query_params)
      chain.where(query_params)
    end

    def apply_pagination(chain)
      @skip_drop_down_pagination = true
      records = chain.to_a
      Kaminari.paginate_array(records).page(1).per(records.size)
    end
  end

  index do
    id_column
    column :name
    column :parent_table
    column :date_from
    column :date_to
    column :size
    column :total_size
    column :approximate_row_count
  end

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :name
          row :parent_table
          row :date_from
          row :date_to
          row :partition_range
        end
      end
      column do
        attributes_table title: 'Table Details' do
          row :size
          row :total_size
          row :approximate_row_count
        end
      end
    end
  end
end

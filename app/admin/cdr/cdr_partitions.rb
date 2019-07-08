# frozen_string_literal: true

ActiveAdmin.register PartitionModel::Cdr, as: 'CDR Partition' do
  menu parent: 'CDR', label: 'CDR Partitions'

  actions :index

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
    column :name
    column :parent_table
    column :date_from
    column :date_to
    column :size
    column :total_size
    column :approximate_row_count
  end
end

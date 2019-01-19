# frozen_string_literal: true

module ResourceDSL
  module ActsAsExport
    def acts_as_export(*c_names)
      # c_names = config.resource_class.column_names if c_names.empty?
      # xlsx do
      #   clear_columns
      #   c_names.each do |c_name|
      #     if c_name.is_a?(Array)
      #       column(c_name[0]) do |row|
      #         c_name[1].call(row)
      #       end
      #     else
      #       column(c_name.to_sym)
      #     end
      #   end
      # end

      if c_names.present?
        csv do
          c_names.each do |c_name|
            if c_name.is_a?(Array)
              column(c_name[0]) do |row|
                c_name[1].call(row)
              end
            else
              column(c_name.to_sym)
            end
          end
        end
      end
    end
  end
end

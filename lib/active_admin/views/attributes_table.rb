module ActiveAdmin
  module Views
    class AttributesTable
      def bool_row(attribute, *args)
        row(attribute, *args) { |model| model.send(attribute) ? status_tag("yes", :ok) : status_tag("no") }
      end

      def find_attr_value(record, attr)
        if attr.is_a?(Proc)
          attr.call(record)
        elsif attr =~ /\A(.+)_id\z/ && reflection_for(record.class, $1.to_sym)
          record.public_send $1
        elsif record.respond_to? attr

          value =  record.public_send attr
          if value.in? [true, false]
            status_tag(value.to_s)
          else
            value
          end

        elsif record.respond_to? :[]
          record[attr]
        end
      end
      ########

    end
  end
end
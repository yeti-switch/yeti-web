module ActiveAdmin
  module Inputs
    module Filters
      class StringEqInput < ::Formtastic::Inputs::StringInput
        include Base
      #  include Base::SearchMethodSelect

        def to_html
          input_wrapping do
            label_html <<
                builder.text_field(input_name, input_html_options)
          end
        end

        def input_name
          "#{super}_eq"
        end


      end
    end
  end
end
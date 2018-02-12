require 'spec_helper'

RSpec.describe CustomersAuth, type: :model do

  shared_examples :it_validates_array_elements do |*columns|
    columns.each do |column_name|
      # uniquness
      it { is_expected.not_to allow_value(['127.0.0.1', '127.0.0.1']).for(column_name) }
      it { is_expected.to allow_value(['127.0.0.1', '127.0.0.2']).for(column_name) }
      # spaces are not allowed
      it { is_expected.not_to allow_value(['s s', 'asd']).for(column_name) }
      it { is_expected.not_to allow_value(['asd', 'a sd']).for(column_name) }
    end
  end


  context '#validations' do

    context 'validate Routing Tag' do
      include_examples :test_model_with_tag_action
    end

    context 'validate match condition attributes' do

      include_examples :it_validates_array_elements,
        :ip,
        :dst_prefix, :src_prefix,
        :uri_domain, :from_domain, :to_domain,
        :x_yeti_auth
    end
  end

end

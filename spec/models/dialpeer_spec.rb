require 'spec_helper'

describe Dialpeer, type: :model do

  describe 'validations' do

    let(:record) { described_class.new(attributes) }

    before { record.validate }

    subject do
      record.errors.to_h
    end

    context 'without Gateway' do
      let(:attributes) {}

      include_examples :validation_error_on_field, :base, 'Specify a gateway_group or a gateway'
      include_examples :validation_no_error_on_field, :gateway
    end


    context 'with Gateway' do
      let(:attributes) { { gateway: g, vendor_id: vendor.id, gateway_id: g.id } }
      let(:vendor) { g.contractor }
      let(:g) { create(:gateway, g_attr) }
      let(:g_attr) do
        {}
      end

      context 'not allow_termination' do
        let(:g_attr) { { allow_termination: false } }

        include_examples :validation_error_on_field, :gateway, 'must be allowed for termination'
      end
    
      context 'different vendor' do
        let(:vendor) { create(:vendor) }
        let(:g_attr) { { allow_termination: true } }

        include_examples :validation_error_on_field, :gateway, 'must be owned by selected vendor or be shared'
      end

      context 'different vendor, gateway is shared' do
        let(:vendor) { create(:vendor) }
        let(:g_attr) { { allow_termination: true, is_shared: true } }

        include_examples :validation_no_error_on_field, :gateway
      end

    end

  end

end


# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlists
#
#  id                         :integer(2)       not null, primary key
#  default_dst_rewrite_result :string
#  default_dst_rewrite_rule   :string
#  default_src_rewrite_result :string
#  default_src_rewrite_rule   :string
#  defer_dst_rewrite          :boolean          default(FALSE), not null
#  defer_src_rewrite          :boolean          default(FALSE), not null
#  external_type              :string
#  name                       :string           not null
#  tag_action_value           :integer(2)       default([]), not null, is an Array
#  created_at                 :timestamptz
#  updated_at                 :timestamptz
#  default_action_id          :integer(2)       default(1), not null
#  external_id                :bigint(8)
#  lua_script_id              :integer(2)
#  mode_id                    :integer(2)       default(1), not null
#  tag_action_id              :integer(2)
#
# Indexes
#
#  blacklists_name_key                             (name) UNIQUE
#  numberlists_external_id_external_type_key_uniq  (external_id,external_type) UNIQUE
#  numberlists_external_id_key_uniq                (external_id) UNIQUE WHERE (external_type IS NULL)
#
# Foreign Keys
#
#  numberlists_lua_script_id_fkey  (lua_script_id => lua_scripts.id)
#  numberlists_tag_action_id_fkey  (tag_action_id => tag_actions.id)
#

RSpec.describe Routing::Numberlist do
  describe '.create' do
    subject do
      described_class.create(create_params)
    end

    let(:create_params) do
      { name: 'test' }
    end
    let(:default_attrs) do
      {
        default_dst_rewrite_result: nil,
        default_dst_rewrite_rule: nil,
        default_src_rewrite_result: nil,
        default_src_rewrite_rule: nil,
        external_type: nil,
        tag_action_value: [],
        created_at: be_within(1).of(Time.current),
        updated_at: be_within(1).of(Time.current),
        default_action_id: 1,
        external_id: nil,
        lua_script_id: nil,
        mode_id: 1,
        tag_action_id: nil
      }
    end

    context 'with name' do
      include_examples :creates_record do
        let(:expected_record_attrs) { default_attrs.merge(create_params) }
      end
    end

    context 'with external_type="" and external_id=123' do
      let(:create_params) do
        super().merge external_id: 123,
                      external_type: ''
      end

      include_examples :creates_record do
        let(:expected_record_attrs) { default_attrs.merge(create_params).merge(external_type: nil) }
      end
    end

    context 'with external_id=123' do
      let(:create_params) do
        super().merge external_id: 123
      end

      include_examples :creates_record do
        let(:expected_record_attrs) { default_attrs.merge(create_params) }
      end

      context 'when numberlist with external_id=123,external_type=null exists' do
        before do
          create(:numberlist, external_id: 123)
        end

        include_examples :does_not_create_record, errors: {
          external_id: 'has already been taken'
        }
      end

      context 'when numberlist with external_id=123,external_type="foo" exists' do
        before do
          create(:numberlist, external_id: 123, external_type: 'foo')
        end

        include_examples :creates_record do
          let(:expected_record_attrs) { default_attrs.merge(create_params) }
        end
      end
    end

    context 'with external_type="bar"' do
      let(:create_params) do
        super().merge external_type: 'bar'
      end

      include_examples :does_not_create_record, errors: {
        external_type: 'requires external_id'
      }
    end

    context 'with external_type="foo" and external_id=123' do
      let(:create_params) do
        super().merge external_id: 123,
                      external_type: 'foo'
      end

      include_examples :creates_record do
        let(:expected_record_attrs) { default_attrs.merge(create_params) }
      end

      context 'when numberlist with external_id=123,external_type=null exists' do
        before do
          create(:numberlist, external_id: 123)
        end

        include_examples :creates_record do
          let(:expected_record_attrs) { default_attrs.merge(create_params) }
        end
      end

      context 'when numberlist with external_id=123,external_type="foo" exists' do
        before do
          create(:numberlist, external_id: 123, external_type: 'foo')
        end

        include_examples :does_not_create_record, errors: {
          external_id: 'has already been taken'
        }
      end
    end
  end
end

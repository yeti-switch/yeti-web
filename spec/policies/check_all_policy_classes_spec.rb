# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Role Policy classes' do
  let(:active_admin_resources) do
    ActiveAdmin.application.namespaces[:root].resources
  end
  let(:active_admin_model_resources) do
    active_admin_resources.reject { |res| res.is_a?(ActiveAdmin::Page) }
  end
  let(:active_admin_page_resources) do
    active_admin_resources.select { |res| res.is_a?(ActiveAdmin::Page) }
  end
  let(:yeti_model_resources) do
    active_admin_model_resources.reject { |res| res.resource_class_name =~ /ActiveAdmin::/ }
  end

  describe 'check all resource classes has policies' do
    subject do
      yeti_model_resources.map(&:resource_class_name)
    end

    it 'has all corresponding model policies', :aggregate_failures do
      subject.each do |klass_name|
        policy_klass_name = "#{klass_name}Policy"
        policy_klass = policy_klass_name.safe_constantize
        expect(policy_klass).to be_kind_of(Class)
        policy_klass_ancestors = policy_klass.ancestors.map(&:to_s)
        expect(policy_klass_ancestors).to(
          include('RolePolicy'),
          "expect #{policy_klass} to have RolePolicy in ancestors but it have only #{policy_klass_ancestors}"
        )
      end
    end
  end
end

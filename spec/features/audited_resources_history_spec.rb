# frozen_string_literal: true

# Data-driven guard for the shared history page (app/views/layouts/history.html.arb).
#
# Every ActiveAdmin resource declaring `acts_as_audit` exposes a `/:id/history`
# member action. That view decorates each version's item via `v.item.decorate`,
# which raises Draper::UninferrableDecoratorError for any model whose decorator
# can't be inferred (no decorator, or a non-conventionally-named one).
#
# This spec visits the history page for every audited resource so that class of
# regression is caught for all of them at once, not just the model that happened
# to be reported.
RSpec.describe 'Audited resources: history page' do
  include_context :login_as_admin

  # The history view loads each version's polymorphic item individually, which is
  # an inherent N+1 unrelated to what this spec guards (decoration). Disable Bullet
  # here so that pre-existing N+1 doesn't mask the decorator regression we care about.
  around do |example|
    Bullet.enable = false
    example.run
  ensure
    Bullet.enable = true
  end

  # Builders for models whose factory needs traits/args, or whose factory name
  # doesn't match the model's element name (singletons are reused if present).
  builders = {
    'Contractor' => -> { create(:customer) },
    'DisconnectPolicyCode' => -> { create(:disconnect_policy_code, code: create(:disconnect_code, :sip)) },
    'Billing::Invoice' => -> { create(:invoice, :with_vendor_account) },
    'System::CdrConfig' => -> { System::CdrConfig.first || create(:cdr_config) },
    'GuiConfig' => -> { GuiConfig.first || create(:gui_config) },
    'Cnam::Database' => -> { create(:cnam_database) },
    'Lnp::Database' => -> { create(:lnp_database, :csv) },
    'RateManagement::Project' => -> { create(:rate_management_project, :filled) },
    'RateManagement::Pricelist' => -> { create(:rate_management_pricelist, :with_project) },
    'Equipment::Dns::Record' => -> { create(:dns_record) },
    'Equipment::Dns::Zone' => -> { create(:dns_zone) },
    'Equipment::StirShaken::RcdProfile' => lambda {
      Equipment::StirShaken::RcdProfile.create!(nam: 'Test RCD', icn: 'https://example.com/icon.png', jcl: 'https://example.com')
    },
    'Equipment::StirShaken::SigningCertificate' => -> { create(:stir_shaken_signing_certificate) },
    'Equipment::StirShaken::TrustedCertificate' => -> { create(:stir_shaken_trusted_certificate) },
    'Equipment::StirShaken::TrustedRepository' => -> { create(:stir_shaken_trusted_repository) }
  }

  audited_resources =
    ActiveAdmin.application.namespaces[:root].resources
               .reject { |r| r.is_a?(ActiveAdmin::Page) }
               .select { |r| r.member_actions.any? { |a| a.name.to_sym == :history } }
               .sort_by { |r| r.resource_class.name }

  audited_resources.each do |resource|
    model = resource.resource_class

    describe model.name do
      it 'renders the history page without a decorator error' do
        builder = builders[model.name]
        factory = model.model_name.element.to_sym
        skip "no factory registered for #{model.name}" unless builder || FactoryBot.factories.registered?(factory)

        record = builder ? instance_exec(&builder) : create(factory)
        visit "#{resource.route_collection_path({})}/#{record.id}/history"

        expect(page.status_code).to eq(200)
        expect(page).to have_content('History')
      end
    end
  end
end

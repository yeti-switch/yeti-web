# frozen_string_literal: true

require 'spec_helper'

# Guards the vendor -> account tom-select fill race (see
# app/assets/javascripts/tom-select-ajax-fillable.js). Selecting the Vendor
# kicks off an async fillOptions() fetch for the dependent Account field; the
# Account is then filled immediately, while that request is still in flight.
# The late response must NOT clobber the value the user just picked.
#
# This spec forces the race deterministically by delaying the /accounts/search
# response client-side so it always resolves after the Account is selected.
# Before the fix the async ts.clear() wiped the selection and the form failed
# with "Account must exist"; that flake bounced between the create/update specs
# for several commits before being fixed at the source.
RSpec.describe 'Rate Management Project Account fill race', js: true, bullet: [:n] do
  include_context :login_as_admin

  let!(:vendor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, contractor: vendor) }

  it 'keeps the selected account after the delayed fetch resolves' do
    visit new_rate_management_project_path

    # Delay every /accounts/search response so it resolves after the Account is
    # selected below, guaranteeing the in-flight race is exercised.
    page.execute_script(<<~JS)
      (function () {
        var orig = window.fetch;
        window.fetch = function (url) {
          var p = orig.apply(this, arguments);
          if (String(url).indexOf('/accounts/search') !== -1) {
            return p.then(function (r) {
              return new Promise(function (res) { setTimeout(function () { res(r); }, 800); });
            });
          }
          return p;
        };
      })();
    JS

    fill_in_tom_select 'Vendor', with: vendor.name, search: true
    select_tom_select_by_value 'Account', { account.id => account.name }

    # Wait past the delayed fetch's resolution, then assert the submitted value
    # (account_id) survived the async options rebuild.
    sleep 1.5

    selected_value = page.evaluate_script(
      "document.getElementById('rate_management_project_account_id').value"
    )
    expect(selected_value).to eq(account.id.to_s)
  end
end

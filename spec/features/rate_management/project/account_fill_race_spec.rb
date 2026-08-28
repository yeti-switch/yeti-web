# frozen_string_literal: true

require 'spec_helper'

# Guards the vendor -> account fill race of the ajax fillable tom-select, see
# app/assets/javascripts/tom-select-ajax-fillable.js. Selecting the Vendor kicks
# off an async fillOptions() request for the dependent Account field, and the
# Account is filled while that request is still in flight. The late response
# rebuilds the options of the Account field and must keep the value that was
# selected meanwhile, otherwise the form is submitted without an account and
# fails with "Account must exist".
#
# The race is made deterministic by delaying the /accounts/search response, so
# it always resolves after the account was selected.
RSpec.describe 'Rate Management Project account fill race', js: true, bullet: [:n] do
  include_context :login_as_admin

  let!(:vendor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, contractor: vendor) }
  let(:account_select_value) do
    page.evaluate_script("document.getElementById('rate_management_project_account_id').value")
  end

  before do
    visit new_rate_management_project_path
    delay_accounts_search
  end

  it 'keeps selected account when delayed response arrives' do
    fill_in_tom_select 'Vendor', with: vendor.name, search: true
    select_tom_select_by_value 'Account', { account.id => account.name }

    # selected option is re-rendered with the label returned by the server, so
    # this matcher passes only after the delayed response rebuilt the options,
    # and only when rebuilding kept the selection
    expect(page).to have_field_tom_select 'Account', with: account.display_name
    expect(account_select_value).to eq account.id.to_s
  end

  def delay_accounts_search
    page.execute_script(<<~JS)
      (function () {
        var orig = window.fetch
        window.fetch = function (url) {
          var response = orig.apply(this, arguments)
          if (String(url).indexOf('/accounts/search') === -1) return response

          return response.then(function (r) {
            return new Promise(function (resolve) { setTimeout(function () { resolve(r) }, 1200) })
          })
        }
      })()
    JS
  end
end

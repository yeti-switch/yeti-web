# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/shared_examples_for_importing_job'

describe 'Importing::Account => Account delayed_job' do
  it_behaves_like 'Jobs for importing data' do
    include_context :init_importing_delayed_job do
      include_context :init_contractor
      include_context :init_importing_account
      let(:preview_class) { Importing::Account }
    end
  end
end

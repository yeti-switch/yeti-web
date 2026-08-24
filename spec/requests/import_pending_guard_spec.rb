# frozen_string_literal: true

# The pending-import guard lives in lib/resource_dsl/acts_as_import.rb. It must cover
# the ":do_import" upload as well as the ":import" form, otherwise a browser "back" (or
# a second tab) lets the same form be POSTed again and a second CSV is appended to the
# staging table of the session that is already running.
RSpec.describe 'Pending import session guard', type: :request do
  include_context :login_as_admin

  let(:csv_path) { Rails.root.join('spec/fixtures/files/import_contractors.csv') }
  let(:csv_file) { Rack::Test::UploadedFile.new(csv_path, 'text/csv') }

  # The test env keeps allow_forgery_protection on, so the upload POST needs a token
  # from a real session. Take it from the resource index rather than the import form:
  # the form itself is behind the guard under test.
  def csrf_token
    get contractors_path
    Nokogiri::HTML(response.body).at('meta[name="csrf-token"]')&.[]('content')
  end

  def upload_csv
    post do_import_contractors_path,
         params: {
           importing_model: {
             file: csv_file,
             csv_options: { col_sep: ',', row_sep: '', quote_char: '' }
           }
         },
         headers: { 'X-CSRF-Token' => csrf_token }
  end

  context 'with no import session in progress' do
    it 'accepts the upload' do
      expect { upload_csv }.to change(Importing::Contractor, :count).by(2)
    end
  end

  context 'when a session of the same import is already in progress' do
    let!(:pending) { create(:importing_contractor) }

    it 'rejects the upload instead of appending a second CSV' do
      expect { upload_csv }.not_to change(Importing::Contractor, :count)

      expect(response).to redirect_to(importing_contractors_path)
      expect(flash[:notice]).to eq('Please finish your previous import session.')
    end

    it 'rejects the form as well' do
      get import_contractors_path

      expect(response).to redirect_to(importing_contractors_path)
    end
  end

  # Importing::Numberlist, ::NumberlistItem and ::RateGroup used to be missing from the
  # hardcoded REGISTERED_IMPORTS list, so a session of theirs was invisible to the guard.
  context 'when a session of an import that was missing from the registry is in progress' do
    let!(:pending) { create(:importing_numberlist_item) }

    it 'is seen by the guard' do
      get import_routing_numberlist_items_path

      expect(response).to redirect_to(numberlist_item_imports_path)
      expect(flash[:notice]).to eq('Please finish your previous import session.')
    end
  end

  describe 'the registry itself' do
    it 'covers every Importing model that has an import preview' do
      registered = ResourceDSL::ActsAsImportPreview.registered_imports

      declared = Dir[Rails.root.join('app/models/importing/*.rb')].map do |path|
        File.basename(path, '.rb')
      end - %w[base model importing_delayed_job]

      expect(registered.map { |name| name.demodulize.underscore }).to match_array(declared)
    end
  end
end

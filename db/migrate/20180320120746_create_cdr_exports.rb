class CreateCdrExports < ActiveRecord::Migration
  def change
    create_table 'sys.cdr_exports' do |t|
      t.string :status, null: false
      t.string :fields, default: [], array: true, null: false
      t.json :filters, default: {}, null: false
      t.string :callback_url
      t.string :type, null: false
      t.timestamps
    end
  end
end

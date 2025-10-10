# frozen_string_literal: true

class AddRolledbackAtField < ActiveRecord::Migration[7.2]
  def change
    add_column :payments, :rolledback_at, :timestamptz
  end
end

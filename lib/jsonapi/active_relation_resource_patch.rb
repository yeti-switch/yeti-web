# frozen_string_literal: true

# Fix schema-qualified table names in the resource-set query builder.
#
# JSONAPI::ActiveRelationResource builds raw SQL for the SELECT list and quotes
# the table name with quote_column_name. For a schema-qualified table such as
# "billing.accounts" that yields a single mangled identifier ("billing.accounts")
# instead of "billing"."accounts", producing
#   PG::UndefinedTable: missing FROM-clause entry for table "billing.accounts"
# This app uses schema-qualified tables throughout, so quote the table portion
# with quote_table_name (which splits schema and table) instead.
module ActiveRelationResourceSchemaQualifiedPatch
  def concat_table_field(table, field, quoted = false)
    return super unless quoted
    return super if table.blank? || field.to_s.include?('.')

    "#{_model_class.connection.quote_table_name(table.to_s)}.#{quote(field)}"
  end
end

JSONAPI::ActiveRelationResource.singleton_class.prepend(ActiveRelationResourceSchemaQualifiedPatch)

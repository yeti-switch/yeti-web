# frozen_string_literal: true

require 'base64'

class Api::RestController < ApiController
  respond_to :json
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from AbstractController::ActionNotFound, with: :render_404

  def render_404(_e = nil)
    render status: 404, nothing: true
  end

  protected

  def apply_search(chain)
    if params[:q]&.any?
      chain.ransack(params[:q]).result
    else
      chain
    end
  end

  def apply_pagination(chain)
    chain.page(params[:page] || 1).per(per_page)
  end

  def apply_sorting(chain)
    klass = chain.klass
    params[:order] ||= (klass.respond_to?(:primary_key) ? klass.primary_key.to_s : 'id') + '_desc'
    if params[:order] && params[:order] =~ /^([\w\_\.]+)_(desc|asc)$/
      column = Regexp.last_match(1)
      order = Regexp.last_match(2)
      table = klass.column_names.include?(column) ? klass.quoted_table_name : nil
      table_column = /\./.match?(column) ? column :
          [table, klass.connection.quote_column_name(column)].compact.join('.')

      chain.reorder(Arel.sql("#{table_column} #{order}"))
    else
      chain # just return the chain
    end
  end

  def resource_collection(scope)
    scope = apply_search(scope)
    scope = apply_pagination(scope)
    scope = apply_sorting(scope)
    scope
  end

  def send_x_headers(collection)
    %w[total_count offset_value limit_value num_pages current_page].each do |x|
      response.headers["X-#{x.titleize.gsub(/\s/, '-')}"] = collection.send(x).to_s
    end
  end

  def per_page
    @per_page ||= params[:per_page] ||= default_per_page
  end

  def default_per_page
    50
  end

  def user_for_paper_trail
    'REST API'
  end

  # todo:
  def restrict_access
    true
  end
end

# frozen_string_literal: true

module WithCreateTemplate
  extend ActiveSupport::Concern

  included do
    private :create_from_template, :template_content
  end

  def create_from_template(source, destination, *args)
    create_file(destination, *args) { template_content(source) }
  end

  def template_content(source)
    source = File.expand_path(find_in_source_paths(source.to_s))
    # context = instance_eval("binding")
    context = send(:binding)

    match = ERB.version.match(/\Aerb\.rb \[(?<version>[^ ]+) /)
    if match && match[:version] >= '2.2.0' # Ruby 2.6+
      ERB.new(::File.binread(source), trim_mode: '-', eoutvar: '@output_buffer').result(context)
    else
      ERB.new(::File.binread(source), nil, '-', '@output_buffer').result(context) # rubocop:disable Lint/ErbNewArguments
    end
  end
end

# frozen_string_literal: true

# Liquid-backed template columns on a model: render them, and reject a template
# that could not render before it is stored.
#
# Rendering is deliberately lenient and validation deliberately strict. A save
# is a human at a keyboard who can fix a typo immediately, so unknown variables
# and syntax errors become validation errors there. A render happens inside a
# background job that is delivering something (an invoice, a balance alert), so
# it degrades to a blank for the offending variable and logs, rather than
# wedging the job over a cosmetic problem.
module LiquidTemplate
  extend ActiveSupport::Concern

  class_methods do
    # @param attributes [Array<Symbol>] template columns to check on save
    # @param sample [Proc] returns the assigns hash a valid template may use;
    #   anything outside it is an unknown variable, which is the point — the
    #   documented contract is enforced at save time.
    def validates_liquid_syntax(*attributes, sample:)
      validate do
        assigns = instance_exec(&sample).deep_stringify_keys

        attributes.each do |attribute|
          source = self[attribute]
          next if source.blank?

          begin
            parse_liquid(source).render!(assigns, strict_variables: true)
          rescue Liquid::SyntaxError => e
            errors.add(attribute, "liquid syntax error: #{e.message}")
          rescue Liquid::UndefinedVariable => e
            errors.add(attribute, "unknown variable: #{e.message}")
          rescue Liquid::Error => e
            errors.add(attribute, "liquid error: #{e.message}")
          end
        end
      end
    end
  end

  private

  def render_liquid(source, assigns)
    template = parse_liquid(source)
    template.errors.clear # parse memoizes the template; only log this render's errors
    output = template.render(assigns.deep_stringify_keys, strict_variables: true)
    if template.errors.any?
      Rails.logger.warn { "#{self.class.name}##{id} render: #{template.errors.map(&:message).join('; ')}" }
    end
    output
  end

  def parse_liquid(source)
    (@parsed_liquid ||= {})[source] ||= Liquid::Template.parse(source, error_mode: :strict)
  end
end

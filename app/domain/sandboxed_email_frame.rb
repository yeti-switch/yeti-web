# frozen_string_literal: true

module SandboxedEmailFrame
  module_function

  def render(html, style: 'width:100%;min-height:400px')
    escaped = ERB::Util.html_escape(html.to_s)
    frame_style = "#{style};border:1px solid #ddd;background:#fff"
    %(<iframe sandbox srcdoc="#{escaped}" style="#{frame_style}" title="Email body"></iframe>).html_safe
  end
end

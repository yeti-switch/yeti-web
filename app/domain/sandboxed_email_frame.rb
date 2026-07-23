# frozen_string_literal: true

# Renders untrusted email HTML (notification templates, and any other body
# persisted into Log::EmailLog#msg) inside a sandboxed iframe.
#
# The single place where email bodies are shown to an admin. An empty `sandbox`
# withholds allow-scripts, so a stored script cannot run in the admin's session —
# a privilege-escalation vector, since editing a template and holding a higher
# role are separate permissions. Inline styles and images still render, so the
# preview matches the delivered email; isolating the body in its own document is
# also how a real mail client renders it. The guarantee lives in the markup (the
# attribute), not a response header, so no proxy or CSP rewrite can weaken it.
# `srcdoc` is attribute-escaped so the markup cannot break out of the iframe.
#
# A plain module rather than a view helper so both the controller (preview
# member_action) and the ActiveAdmin view context can call it — ApplicationHelper
# is not mixed into ActiveAdmin's view context.
module SandboxedEmailFrame
  module_function

  def render(html, style: 'width:100%;min-height:400px')
    escaped = ERB::Util.html_escape(html.to_s)
    frame_style = "#{style};border:1px solid #ddd;background:#fff"
    %(<iframe sandbox srcdoc="#{escaped}" style="#{frame_style}" title="Email body"></iframe>).html_safe
  end
end

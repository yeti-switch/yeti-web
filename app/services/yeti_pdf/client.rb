# frozen_string_literal: true

require 'httpx'

# Client for the external yeti-pdf render service: POSTs a pongo2 template plus
# a JSON data payload and returns either the rendered PDF bytes (#render_pdf)
# or the merged HTML (#render_html — a cheap pongo2 merge with no PDF step).
module YetiPdf
  class Client
    class Error < StandardError; end

    RENDER_PATH = '/v1/render'
    RENDER_HTML_PATH = '/v1/render/html'
    DEFAULT_TIMEOUT = 30

    class << self
      def render_pdf(...)
        new.render_pdf(...)
      end

      def render_html(...)
        new.render_html(...)
      end

      # Whether the render service is configured (base_url present). When it is
      # not, invoice generation records a PdfApiNotConfigured error.
      def configured?
        YetiConfig.invoice&.pdf_api&.base_url.present?
      end
    end

    # @return [String] binary PDF bytes
    def render_pdf(template:, data:, options: {})
      post(RENDER_PATH, template: template, data: data, options: options)
    end

    # @return [String] the merged HTML (pre-PDF); useful for debugging/preview
    def render_html(template:, data:, options: {})
      post(RENDER_HTML_PATH, template: template, data: data, options: options)
    end

    private

    def post(path, template:, data:, options:)
      cfg = YetiConfig.invoice&.pdf_api
      raise Error, 'invoice.pdf_api.base_url is not configured' if cfg&.base_url.blank?

      response = client(cfg).post(url(cfg, path), json: { template: template, data: data, options: options })
      response.raise_for_status
      response.body.to_s
    rescue HTTPX::HTTPError => e
      raise Error, "yeti-pdf returned HTTP #{e.status}: #{safe_body(e.response)}"
    rescue HTTPX::Error => e
      raise Error, "yeti-pdf request failed: #{e.message}"
    end

    def client(cfg)
      t = (cfg.timeout || DEFAULT_TIMEOUT).to_i
      # Rendering a large invoice can take yeti-pdf minutes, so the client must
      # wait for the response. HTTPX's read/write timeouts default to 60s and
      # fire independently of request_timeout, so raise all of them to the
      # configured value — otherwise "Timed out after 60 seconds" hits first.
      HTTPX.with(
        timeout: {
          read_timeout: t,
          write_timeout: t,
          request_timeout: t
        },
        headers: headers(cfg)
      )
    end

    def url(cfg, path)
      "#{cfg.base_url.to_s.chomp('/')}#{path}"
    end

    def headers(cfg)
      h = {}
      h['Authorization'] = "Bearer #{cfg.auth_token}" if cfg.auth_token.present?
      h
    end

    def safe_body(response)
      response&.body&.to_s.to_s.truncate(500)
    end
  end
end

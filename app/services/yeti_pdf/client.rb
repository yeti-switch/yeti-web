# frozen_string_literal: true

require 'httpx'

# Client for the external yeti-pdf render service: POSTs a pongo2 template plus
# a JSON data payload and returns either the rendered PDF and the name to file
# it under (#render_pdf) or the merged HTML (#render_html — a cheap pongo2
# merge with no PDF step).
module YetiPdf
  class Client
    class Error < StandardError; end

    RENDER_PATH = '/v1/render'
    RENDER_HTML_PATH = '/v1/render/html'
    DEFAULT_TIMEOUT = 30
    PDF_EXTENSION = '.pdf'

    # What #render_pdf hands back: the document and the name to file it under,
    # both produced by a single render request. #filename is nil unless a
    # filename_template was sent.
    Result = Struct.new(:pdf, :filename)

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

    # Renders the document and the name to store it under — one request, one
    # data payload, both templates merged by yeti-pdf. A filename template that
    # renders to something unusable (empty, a path separator, a control
    # character) fails the whole request there, so a bad name never reaches us.
    #
    # filename_template is required: yeti-web always names its documents, so
    # every Content-Disposition on the response is a name we asked for. The
    # endpoint itself allows the field to be omitted, but no caller here does.
    #
    # @return [Result] the PDF bytes and the rendered filename (nil only if
    #   yeti-pdf answered without one)
    def render_pdf(template:, data:, filename_template:, options: {})
      response = post(RENDER_PATH, template: template, data: data, options: options,
                                   filename_template: filename_template)
      Result.new(response.body.to_s, rendered_filename(response))
    end

    # @return [String] the merged HTML (pre-PDF); useful for debugging/preview
    def render_html(template:, data:, options: {})
      post(RENDER_HTML_PATH, template: template, data: data, options: options).body.to_s
    end

    private

    # Every keyword becomes a field of the JSON body, so each endpoint sends
    # exactly the keys it was given — render_html has no filename_template to
    # pass and therefore never sends one.
    def post(path, **payload)
      cfg = YetiConfig.invoice&.pdf_api
      raise Error, 'invoice.pdf_api.base_url is not configured' if cfg&.base_url.blank?

      proxy = proxy_for(cfg)
      http = proxy.apply(client(cfg))
      response = proxy.run { http.post(url(cfg, path), json: payload) }
      response.raise_for_status
      response
    rescue HTTPX::HTTPError => e
      raise Error, "yeti-pdf returned HTTP #{e.status}: #{safe_body(e.response)}"
    rescue HTTPX::Error => e
      raise Error, "yeti-pdf request failed: #{e.message}"
    end

    # yeti-pdf returns the rendered name in Content-Disposition with a ".pdf"
    # extension (so the response is directly saveable); we store the base name
    # and re-append the extension when serving. httpx parses both the quoted
    # and the RFC 2231 filename*=utf-8'' forms.
    def rendered_filename(response)
      name = response.body.filename
      return if name.blank?

      name.delete_suffix(PDF_EXTENSION)
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

    # Outbound HTTP proxy for yeti-pdf calls (usually an internal service, so it
    # defaults to direct); see HttpxProxy and invoice.pdf_api.* in yeti_web.yml.
    def proxy_for(cfg)
      HttpxProxy.new(http_proxy: cfg.http_proxy, use_env_proxy: cfg.use_env_proxy)
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

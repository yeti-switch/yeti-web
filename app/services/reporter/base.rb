# frozen_string_literal: true

module Reporter
  class Base < ::BaseService
    attr_reader :report, :options

    CsvData = Struct.new(:columns, :collection)

    EmailData = Struct.new(:columns, :collection, :decorator, :footers) do
      def decorated_collection
        decorator ? decorator.decorate_collection(collection) : collection
      end

      def footer(column)
        return unless footers

        column = column.is_a?(Array) ? column.first : column
        footers[column]
      end

      def column_title(column)
        column = column.is_a?(Array) ? column.last : column
        column.is_a?(Symbol) ? column.to_s.humanize : column
      end

      def column_value(row, column)
        column = column.is_a?(Array) ? column.first : column
        value = row.public_send(column)
        value.respond_to?(:display_name) ? value.display_name : value
      end
    end

    def initialize(report, options = {})
      @report = report
      @options = options
    end

    def save!
      return unless contacts.any?

      contacts.each do |contact|
        next unless contact.smtp_connection

        ::Log::EmailLog.create!(
          contact_id: contact.id,
          smtp_connection_id: contact.smtp_connection.id,
          mail_to: contact.email,
          mail_from: contact.smtp_connection.from_address,
          subject: email_subject,
          attachment_id: generate_attachments(csv_data),
          msg: generate_mail_body(email_data)
        )
      end
    end

    def email_subject
      'Report'
    end

    def csv_data
      raise 'implement me'
    end

    def email_data
      raise 'implement me'
    end

    protected

    def contacts
      unless instance_variable_defined?(:@contacts)
        @contacts ||= ::Billing::Contact.where(id: report.send_to)
      end
      @contacts
    end

    def generate_attachments(data)
      return [] if options[:skip_attachments]

      data.map do |data_item|
        file_name = generate_csv_file(data_item)
        attachment = ::Notification::Attachment.create!(
          filename: file_name
        )
        ::Notification::Attachment.where(id: attachment.id).update_all(data: File.read(file_name))
        attachment.id
      end
    end

    def generate_csv_file(data_item)
      columns = data_item.columns
      data = data_item.collection
      file_name = csv_file_name
      CSV.open(file_name, 'w') do |csv|
        csv << columns.map { |c| c.to_s.humanize }
        data.each do |row|
          line = []
          columns.each do |column|
            ceil = row.send(column)
            ceil = ceil.display_name if ceil.respond_to?(:display_name)
            line << ceil
          end
          csv << line
        end
      end
      file_name
    end

    def csv_file_name
      '/tmp/' + make_tmpname(["#{report.id}_#{report.class.to_s.parameterize}", '.csv'], nil)
    end

    def html_template_name
      File.join(template_path, 'base.html.erb')
    end

    def generate_mail_body(data)
      return if options[:skip_mail_body]

      path_set = ActionView::PathSet.new([template_path])
      lookup = ActionView::LookupContext.new(path_set)
      view = ActionView::Base.new(lookup, {})
      view.render(
        file: html_template_name,
        layout: false,
        locals: {
          data: data,
          report: report,
          service: self
        }
      )
    end

    # Copy implementation of Dir::Tmpname.make_tmpname from ruby 2.3
    # Was removed in ruby 2.5
    def make_tmpname((prefix, suffix), n)
      prefix = (String.try_convert(prefix) ||
          raise(ArgumentError, "unexpected prefix: #{prefix.inspect}"))
      suffix &&= (String.try_convert(suffix) ||
          raise(ArgumentError, "unexpected suffix: #{suffix.inspect}"))
      t = Time.now.strftime('%Y%m%d')
      # $$ - Process ID
      path = "#{prefix}#{t}-#{$PROCESS_ID}-#{rand(0x100000000).to_s(36)}"
      path += "-#{n}" if n
      path += suffix if suffix
      path
    end

    def template_path
      Rails.root.join('app/views/mail_reports').to_s
    end
  end
end

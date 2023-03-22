# frozen_string_literal: true

module SendReport
  class Base < ApplicationService
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

    parameter :report
    parameter :skip_attachments, default: false
    parameter :skip_mail_body, default: false

    def call
      return unless contacts.any?

      contacts.each do |contact|
        create_email_log!(contact)
      end
    end

    private

    def create_email_log!(contact)
      return unless contact.smtp_connection

      ContactEmailSender.new(contact).send_email(
        subject: email_subject,
        message: generate_mail_body(email_data),
        attachments: generate_attachments(csv_data)
      )
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

    def contacts
      unless instance_variable_defined?(:@contacts)
        @contacts ||= ::Billing::Contact.where(id: report.send_to)
      end
      @contacts
    end

    def generate_attachments(data)
      return [] if skip_attachments

      data.map do |data_item|
        file_name = generate_csv_file(data_item)
        attachment = ::Notification::Attachment.create!(
          filename: file_name
        )
        ::Notification::Attachment.where(id: attachment.id).update_all(data: File.read(file_name))
        attachment
      end
    end

    def generate_csv_file(data_item)
      columns = data_item.columns
      data = data_item.collection
      file_name = csv_file_name
      CSV.open(file_name, 'w') do |csv|
        csv << columns.map { |column_name, _attribute| column_name.to_s.humanize }
        data.each do |row|
          line = []
          columns.each do |column_name, attribute_name|
            ceil = row.send(attribute_name || column_name)
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
      'base'
    end

    def generate_mail_body(data)
      return if skip_mail_body

      view = ActionView::Base
             .with_empty_template_cache
             .with_view_paths([template_path], {})

      view.render(
        template: html_template_name,
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

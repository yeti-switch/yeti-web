module Reporter
  class Base < ::BaseService
    attr_reader :report, :options

    CsvData = Struct.new(:columns, :collection)

    EmailData = Struct.new(:columns, :collection, :decorator, :footers) do
      def decorated_collection
        decorator ? decorator.decorate_collection(collection) : collection
      end

      def footer(column)
        return unless self.footers
        column = column.is_a?(Array) ? column.first : column
        self.footers[column]
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
          ::Log::EmailLog.create!(
              contact_id: contact.id,
              smtp_connection_id: contact.smtp_connection.id,
              mail_to: contact.email,
              mail_from: contact.smtp_connection.from_address,
              subject: email_subject,
              attachment_id: generate_attachments(csv_data),
              msg: generate_mail_body(email_data)
          ) if contact.smtp_connection
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
      CSV.open(file_name, "w") do |csv|
        csv << columns.map{|c| c.to_s.humanize }
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
      '/tmp/' + Dir::Tmpname.make_tmpname(["#{report.id}_#{report.class.to_s.parameterize}", '.csv'], nil)
    end

    def html_template_name
      'base.html.erb'
    end

    def generate_mail_body(data)
      return if options[:skip_mail_body]

      view = ActionView::Base.new("#{Rails.root}/app/views/mail_reports", {})
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

  end

end
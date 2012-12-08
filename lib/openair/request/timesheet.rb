module OpenAir::Request
  class Timesheet
    class << self

      def request(request_options, auth_options, query_options = {})
        login_elements = Login.elements(auth_options)

        options = read_options(query_options)
        filters = read_filters(query_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) {
            xml.Auth { xml.parent << login_elements }

            xml.Read(options) {
              filters.each do |filter|
                xml.parent << filter.elements
              end
            }
          }
        end.doc
      end

      private

      def read_options(query_options)
        options = { type: "Timesheet", limit: DEFAULT_LIMIT }

        user_method = query_options[:users] ? "user" : "all"
        options.merge!(method: user_method)

        newer_than, older_than = query_options.values_at(:newer_than, :older_than)
        date_filter = if newer_than && older_than
          {filter: "newer-than,older-than", field: "starts,starts"}
        elsif newer_than
          {filter: "newer-than", field: "starts"}
        elsif older_than
          {filter: "older-than", field: "starts"}
        end
        options.merge!(date_filter) if date_filter

        options
      end

      def read_filters(query_options)
        [
          user_filters_doc(query_options),
          date_filters_doc(query_options)
        ].flatten
      end

      def user_filters_doc(query_options)
        user_ids = query_options[:users]

        Nokogiri::XML::Builder.new do |xml|
          xml.root {
            Array(user_ids).each do |user_id|
              xml.User {
                xml.id user_id
              }
            end
          }
        end.doc.at("root")
      end

      def date_filters_doc(query_options)
        newer_than, older_than = query_options.values_at(:newer_than, :older_than)

        Nokogiri::XML::Builder.new do |xml|
          xml.root {
            if newer_than
              xml.Date {
                xml.year newer_than.year
                xml.month newer_than.month
                xml.day newer_than.day
                xml.hour newer_than.hour
                xml.minute newer_than.min
                xml.second newer_than.sec
              }
            end
            if older_than
              xml.Date {
                xml.year older_than.year
                xml.month older_than.month
                xml.day older_than.day
                xml.hour older_than.hour
                xml.minute older_than.min
                xml.second older_than.sec
              }
            end
          }
        end.doc.at("root")
      end

    end
  end
end


module OpenAir::Request
  class Timesheet
    class << self

      def request(request_options, auth_options, query_options = {})
        login_elements = Login.elements(auth_options)

        read_options = { type: "Timesheet", limit: DEFAULT_LIMIT }
        if users = query_options[:users]
          read_options.merge!(method: "user")
          filter_elements = user_elements(users)
        else
          read_options.merge!(method: "all")
        end

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) {
            xml.Auth { xml.parent << login_elements }

            xml.Read(read_options) {
              xml.parent << filter_elements if filter_elements
            }
          }
        end.doc
      end

      private

      def user_elements(users)
        Nokogiri::XML::Builder.new do |xml|
          xml.root {
            Array(users).each do |user_id|
              xml.User {
                xml.id user_id
              }
            end
          }
        end.doc.at("root").elements
      end

    end
  end
end


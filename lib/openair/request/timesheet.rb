module OpenAir::Request
  class Timesheet
    class << self
      def request(request_options, auth_options)
        login_elements = Login.elements(auth_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }

            xml.Read(type: "Timesheet", filter: "newer-than,older-than", field: "starts,starts", method: "all", limit: "1") do
              xml.Date do
                xml.year "2012"
                xml.month "10"
                xml.day "01"
              end
              xml.Date do
                xml.year "2012"
                xml.month "11"
                xml.day "01"
              end
            end
          end
        end.doc
      end
    end
  end
end


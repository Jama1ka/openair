module OpenAir::Request
  class User
    class << self
      def request(request_options, auth_options)
        login_elements = Login.elements(auth_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }

            xml.Read(type: "User", method: "all", limit: "300")
          end
        end.doc
      end
    end
  end
end


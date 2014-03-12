module OpenAir::Request
  class Project
    class << self
      def request(request_options, auth_options, start_record, limit)
        login_elements = Login.elements(auth_options)

        if start_record && limit
          limit = "#{start_record}, #{limit}"
        else
          limit = DEFAULT_LIMIT
        end

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }
            xml.Read(
              type: "Project",
              method: "all",
              enable_custom: "1",
              limit: limit
            )
          end
        end.doc
      end
    end
  end
end


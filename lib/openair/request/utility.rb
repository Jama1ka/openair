class OpenAir::Request::Utility
  class << self
    def time_request(request_options)
      Nokogiri::XML::Builder.new do |xml|
        xml.request(request_options) do
          xml.Time
        end
      end.doc
    end

    def whoami_request(request_options, auth_options)
      login_elements = OpenAir::Request::Login.elements(auth_options)

      Nokogiri::XML::Builder.new do |xml|
        xml.request(request_options) do
          xml.Auth { xml.parent << login_elements }
          xml.Whoami
        end
      end.doc
    end
  end
end

module OpenAir::Request
  class Login
    class << self
      def elements(options)
        Nokogiri::XML::Builder.new do |xml|
          xml.Login do
            xml.company(options[:company_id])
            xml.user(options[:username])
            xml.password(options[:password])
          end
        end.doc.elements
      end

      def request(request_options, auth_options)
        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.RemoteAuth { xml.parent << elements(auth_options) }
          end
        end.doc
      end
    end
  end
end


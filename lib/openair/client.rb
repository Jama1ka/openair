class OpenAir::Client
  def initialize(options)
    [:api_key, :api_url, :company_id, :username, :password].each do |key|
      value = options[key] or raise ArgumentError
      instance_variable_set("@#{key}", value)
    end
  end

  def login
    Typhoeus::Request.post(@api_url, :body => login_xml, headers: headers)
  end

  private

  def login_xml
    Nokogiri::XML::Builder.new do |xml|
      xml.request(request_options) do
        xml.RemoteAuth do
          xml.Login do
            xml.company(@company_id)
            xml.user(@username)
            xml.password(@password)
          end
        end
      end
    end.to_xml
  end

  def request_options
    {
      "API_version" => "1.0",
      "client" => "test app",
      "client_ver" => "1.1",
      "namespace" => "default",
      "key" => @api_key
    }
  end

  def headers
    {"Content-Type" => "text/xml; charset=utf-8"}
  end
end

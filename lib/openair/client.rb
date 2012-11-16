class OpenAir::Client
  def initialize(options)
    [:api_key, :api_url, :company_id, :username, :password].each do |key|
      value = options[key] or raise ArgumentError
      instance_variable_set("@#{key}", value)
    end
  end

  def login
    post_query(login_doc)
  end

  def time
    post_query(time_doc)
  end

  def whoami
    post_query(whoami_doc)
  end

  private

  def post_query(query_doc)
    Typhoeus::Request.post(@api_url, :body => query_doc.to_xml, headers: headers)
  end

  def whoami_doc
    Nokogiri::XML::Builder.new do |xml|
      xml.request(request_options) do
        xml.Auth do
          xml.parent << login_fragment.elements
        end
        xml.Whoami
      end
    end.doc
  end

  def time_doc
    Nokogiri::XML::Builder.new do |xml|
      xml.request(request_options) do
        xml.Time
      end
    end.doc
  end

  def login_fragment
    Nokogiri::XML::Builder.new do |xml|
      xml.Login do
        xml.company(@company_id)
        xml.user(@username)
        xml.password(@password)
      end
    end.doc
  end

  def login_doc
    Nokogiri::XML::Builder.new do |xml|
      xml.request(request_options) do
        xml.RemoteAuth do
          xml.parent << login_fragment.elements
        end
      end
    end.doc
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

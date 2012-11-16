class OpenAir::Client
  def initialize(options)
    [:api_key, :api_url, :company_id, :username, :password].each do |key|
      value = options[key] or raise ArgumentError
      instance_variable_set("@#{key}", value)
    end
  end

  def login
    post_request OpenAir::Request::Login.request(request_options, auth_options)
  end

  def time
    post_request(time_doc)
  end

  def whoami
    post_request(whoami_doc)
  end

  def timesheets
    post_request(timesheets_doc)
  end

  private

  def post_request(query_doc)
    Typhoeus::Request.post(@api_url, :body => query_doc.to_xml, headers: headers)
  end

  def whoami_doc
    Nokogiri::XML::Builder.new do |xml|
      xml.request(request_options) do
        xml.Auth { xml.parent << login_elements }
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

  def timesheets_doc
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
    end
  end

  def login_elements
    OpenAir::Request::Login.elements(auth_options)
  end

  def auth_options
    {
      company_id: @company_id,
      username: @username,
      password: @password
    }
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

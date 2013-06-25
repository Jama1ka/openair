module OpenAir
  class Client
    def initialize(options)
      [:api_key, :api_url, :company_id, :username, :password].each do |key|
        value = options[key] or raise ArgumentError
        instance_variable_set("@#{key}", value)
      end
    end

    def login
      post_request Request::Login.request(request_options, auth_options)
    end

    def time
      post_request Request::Utility.time_request(request_options)
    end

    def whoami
      post_request Request::Utility.whoami_request(request_options, auth_options)
    end

    def timesheets(query_options = {})
      post_request Request::Timesheet.request(request_options, auth_options, query_options)
    end

    def users
      post_request Request::User.request(request_options, auth_options)
    end

    def find_user_by_netsuite_id(netsuite_id)
      request = Request::User.find_by_netsuite_id(request_options, auth_options, netsuite_id)
      post_request(request)["response"]["Read"]["User"]
    end

    private

    def post_request(query_doc)
      parser = Nori.new
      response = Typhoeus::Request.post(@api_url, :body => query_doc.to_xml, headers: headers)
      parser.parse(response.body)
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
        "client" => "Skynet",
        "client_ver" => "1.0",
        "namespace" => "default",
        "key" => @api_key
      }
    end

    def headers
      {"Content-Type" => "text/xml; charset=utf-8; standalone='yes'"}
    end
  end
end

module OpenAir
  class Client
    def initialize
      # still needs reword to make a better DSL
    end

    def login(company_id, username, password)
      options = {
        company_id: company_id,
        username: username,
        password: password
      }
      post_request Request::Login.request(request_options, auth_options, options)
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

    def change_user_password(user_id, password)
      request = Request::User.change_password(request_options, auth_options, user_id, password)
      status = post_request(request)["response"]["Modify"]["@status"]
      case status
      when "601"
        raise StandardError, "[OpenAir] Method: ChangePassword Invalid id/code for #{user_id}"
      when "0"
        true
      else
        puts "You gave me -- I have no idea what to do with that."
      end
    end

    def find_user_by_netsuite_id(netsuite_id)
      request = Request::User.find_by_netsuite_id(request_options, auth_options, netsuite_id)
      post_request(request)
    end

    private

    def post_request(query_doc)
      parser = Nori.new
      response = Typhoeus::Request.post(
        OpenAir::Configuration.api_url,
        body:query_doc.to_xml,
        headers: headers,
        ssl_verifypeer: false
      )
      parser.parse(response.body)
    end

    def auth_options
      {
        api_key: OpenAir::Configuration.api_key,
        api_url: OpenAir::Configuration.api_url,
        company_id: OpenAir::Configuration.company_id,
        username: OpenAir::Configuration.username,
        password: OpenAir::Configuration.password
      }
    end

    def request_options
      {
        "API_version" => "1.0",
        "client" => "Skynet",
        "client_ver" => "1.0",
        "namespace" => "default",
        "key" => OpenAir::Configuration.api_key
      }
    end

    def headers
      {"Content-Type" => "text/xml; charset=utf-8; standalone='yes'"}
    end
  end
end

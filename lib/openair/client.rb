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
        false
      end
    end

    def modify_user(user_data)
      request = Request::User.modify(request_options, auth_options, user_data)
      response = post_request(request)
      [response["response"]["Modify"]["@status"], response["response"]["Auth"]["@status"]].each do |error_code|
        check_for_errors(
          error_code,
          user_data.map{|k,v| "#{k}=#{v}"}.join(', ')
        )
      end
      response
    end

    def create_user(user_data)
      request = Request::User.create(request_options, auth_options, user_data)
      response = post_request(request)
      status(response, ["CreateUser", "Auth"], user_data)
      response
    end

    def find_user(field_name, value)
      request = Request::User.find(
        request_options,
        auth_options,
        field_name,
        value
      )
      response = post_request(request)
      status(response, ["Read", "Auth"], Hash[field_name => value])
      response
    end

    def get_utilization(field_name, value)
      request = Request::User.get_target_utilization(
        request_options,
        auth_options,
        field_name,
        value
      )
      response = post_request(request)
      status(response, ["Read", "Auth"], Hash[field_name => value])
      response
    end

    def set_utilization(utilization_data)
      request = Request::User.set_target_utilization(request_options, auth_options, utilization_data)
      response = post_request(request)
      status(response, ["CreateTargetUtilization", "Auth"], utilization_data)
      response
    end

    private

    def post_request(query_doc)
      parser = Nori.new
      response = Typhoeus::Request.post(
        OpenAir::Configuration.api_url,
        body: query_doc.to_xml,
        headers: headers,
        ssl_verifypeer: false
      )
      query_doc.xpath("//*[local-name()='password']").each do |node|
        node.content = "***FILTERED***"
      end
      OpenAir::Configuration.logger.info(query_doc.to_xml)
      doc = Nokogiri::XML(response.body)
      xsl =<<XSL
<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:template match="/">
    <xsl:copy-of select="."/>
  </xsl:template>
</xsl:stylesheet>
XSL
      xslt  = Nokogiri::XSLT(xsl)
      OpenAir::Configuration.logger.info(xslt.transform(doc).to_xml)
      parser.parse(response.body)
    end

    def status(response, status_types, identifier)
      status_types.each do |s|
        check_for_errors(
          response["response"][s]["@status"],
          identifier
        )
      end
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


    def check_for_errors(error_code, identifier)
      case error_code
      when "202"
        raise CreateUserError, "duplicate user nickname #{identifier}"
      when "203"
        raise CreateUserError, "too few arguments #{identifier}"
      when "401"
       raise AuthError, "Auth failed: No such company/user/pass #{identifier}"
      when "416"
        raise AuthError, "User locked #{identifier}"
      when "601"
        # error = "ReadError"
        # message = "Invalid id/code"
        true
      when "602"
        raise ReadError, "Invalid field for #{identifier}"
      when "603"
        raise ReadError, "Invalid type or method #{identifier}"
      when "604"
        raise ReadError, "Invalid type or method #{identifier}"
      when "605"
        raise ReadError, "Limit clause must be specified and be less than the account limit for output data #{identifier}"
      when "0"
        true
      else
        raise StandardError, "We don't know what the hell happened. Error code: #{error_code} #{identifier}"
      end
    end

    # def error_message(error_type, message, identifier)
    #   identifier[:password] = "******" if identifier.has_key?(:password)
    #   identifier = identifier.map{|k,v| "#{k}=#{v}"}.join(', ')
    #   raise OpenAir::Errors.new(error_type, "#{message} (#{identifier})")
    # end
  end
end

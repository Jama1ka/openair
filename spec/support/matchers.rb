RSpec::Matchers.define :have_request_with_headers do
  match do |body_doc|
    body_doc.css("request").tap do |request_doc|
      request_doc.attr("API_version").value == "1.0" &&
        request_doc.attr("client").value == "test app" &&
        request_doc.attr("client_ver").value == "1.1" &&
        request_doc.attr("namespace").value == "default" &&
        request_doc.attr("key").value == api_key.to_s
    end
  end
end

RSpec::Matchers.define :have_request_login do
  match do |body_doc|
    body_doc.css("request > Auth:first-child > Login").tap do |auth_doc|
      auth_doc.css("company").text.should == company_id
      auth_doc.css("user").text.should == username
      auth_doc.css("password").text.should == password
    end
  end

    failure_message_for_should do |body_doc|
      "expected: \n#{body_doc.to_xml}\n to include auth"
    end
end

require "spec_helper"

describe OpenAir::Request::Login do
  let(:company_id) { "Abc" }
  let(:username) { "alice" }
  let(:password) { "password" }
  let(:api_key) { "abc123" }
  let(:request_options) do
    {
      "API_version" => "1.0",
      "client" => "test app",
      "client_ver" => "1.1",
      "namespace" => "default",
      "key" => api_key
    }
  end
  let(:auth_options) do
    {
      company_id: company_id,
      username: username,
      password: password
    }
  end

  describe "#elements" do
    subject { OpenAir::Request::Login.elements(auth_options) }

    it "builds login elements" do
      subject.css("Login").tap do |login_doc|
        login_doc.css("company").text.should == company_id
        login_doc.css("user").text.should == username
        login_doc.css("password").text.should == password
      end
    end
  end

  describe "#request" do
    subject { OpenAir::Request::Login.request(request_options, auth_options) }

    it "builds a login request" do
      subject.should have_request_with_headers
      subject.css("request > RemoteAuth > Login").should be_one
    end
  end
end

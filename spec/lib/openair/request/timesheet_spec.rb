require "spec_helper"

describe OpenAir::Request::Timesheet do
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

  describe "#request" do
    subject { OpenAir::Request::Timesheet.request(request_options, auth_options) }

    it "builds a timesheet read request" do
      subject.should have_request_with_headers_with_key(api_key)
      subject.should have_request_login
      subject.css("request > Read[type='Timesheet'][filter][field][method][limit]").should be_one
    end
  end
end

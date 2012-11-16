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

  describe "#time_request" do
    subject { OpenAir::Request::Utility.time_request(request_options) }

    it "builds a time request" do
      subject.should have_request_with_headers
      subject.css("request > Time").should be_one
    end
  end
end

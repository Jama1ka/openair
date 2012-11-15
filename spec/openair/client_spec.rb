require "spec_helper"

describe OpenAir::Client do
  let(:api_key) { 123 }
  let(:api_url) { "http://api.com" }
  let(:company_id) { "Abc" }
  let(:username) { "alice" }
  let(:password) { "password" }
  let(:options) do
    {
      api_key: api_key,
      api_url: api_url,
      company_id: company_id,
      username: username,
      password: password
    }
  end

  describe "#initialize" do
    it "requires an API key, company ID, username and password" do
      expect{OpenAir::Client.new}.to raise_error(ArgumentError)
      expect{OpenAir::Client.new({})}.to raise_error(ArgumentError)

      expect{OpenAir::Client.new(options)}.to_not raise_error
    end
  end

  describe "#login" do
    subject { OpenAir::Client.new(options).login }

    it "builds a login request" do
      Typhoeus::Request.should_receive(:post) do |url, options|
        url.should == api_url

        body_doc = Nokogiri::XML(options[:body])
        body_doc.css("request") do |request|
          request.attr("API_version").value.should == "1.0"
          request.attr("client").value.should == "test app"
          request.attr("client_ver").value.should == "1.1"
          request.attr("namespace").value.should == "default"
          request.attr("key").value.should == api_key.to_s

          request.css("RemoteAuth > Login") do |login|
            login.css("company").text.should == company_id
            login.css("user").text.should == username
            login.css("password").text.should == password
          end
        end

        options[:headers].should == {"Content-Type" => "text/xml; charset=utf-8"}
      end

      subject
    end
  end
end

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
        options[:headers].should == {"Content-Type" => "text/xml; charset=utf-8"}

        body_doc = Nokogiri::XML(options[:body])
        body_doc.should have_request_with_headers
        body_doc.css("request > RemoteAuth > Login").tap do |login_doc|
          login_doc.css("company").text.should == company_id
          login_doc.css("user").text.should == username
          login_doc.css("password").text.should == password
        end
      end

      subject
    end
  end

  describe "#time" do
    subject { OpenAir::Client.new(options).time }

    it "builds a time request" do
      Typhoeus::Request.should_receive(:post) do |url, options|
        url.should == api_url
        options[:headers].should == {"Content-Type" => "text/xml; charset=utf-8"}

        body_doc = Nokogiri::XML(options[:body])
        body_doc.should have_request_with_headers
        body_doc.css("request > Time").should be_one

      end

      subject
    end
  end

end

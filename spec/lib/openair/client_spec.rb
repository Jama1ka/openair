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
  let(:request) { double(to_xml: "<xml/>") }
  let(:headers) { {"Content-Type" => "text/xml; charset=utf-8"} }

  describe "#initialize" do
    it "requires an API key, company ID, username and password" do
      expect{OpenAir::Client.new}.to raise_error(ArgumentError)
      expect{OpenAir::Client.new({})}.to raise_error(ArgumentError)

      expect{OpenAir::Client.new(options)}.to_not raise_error
    end
  end

  describe "#login" do
    subject { OpenAir::Client.new(options).login }

    it "posts a login request" do
      OpenAir::Request::Login.should_receive(:request).and_return(request)

      Typhoeus::Request.should_receive(:post) do |url, options|
        url.should == api_url
        options[:headers].should == headers
        options[:body].should == "<xml/>"
      end

      subject
    end
  end

  describe "#time" do
    subject { OpenAir::Client.new(options).time }

    it "posts a time request" do
      OpenAir::Request::Utility.should_receive(:time_request).and_return(request)

      Typhoeus::Request.should_receive(:post) do |url, options|
        url.should == api_url
        options[:headers].should == headers
        options[:body].should == "<xml/>"
      end

      subject
    end
  end

  describe "#whoami" do
    subject { OpenAir::Client.new(options).whoami }

    it "builds a whoami request" do
      OpenAir::Request::Utility.should_receive(:whoami_request).and_return(request)

      Typhoeus::Request.should_receive(:post) do |url, options|
        url.should == api_url
        options[:headers].should == headers
        options[:body].should == "<xml/>"
      end

      subject
    end
  end

end

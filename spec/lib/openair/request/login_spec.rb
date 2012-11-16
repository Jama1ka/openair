require "spec_helper"

describe OpenAir::Request::Login do
  let(:company_id) { "Abc" }
  let(:username) { "alice" }
  let(:password) { "password" }
  let(:options) do
    {
      company_id: company_id,
      username: username,
      password: password
    }
  end

  describe "#login" do
    subject { OpenAir::Request::Login.login(options) }

    it "builds a login doc" do
      subject.css("Login").tap do |login_doc|
        login_doc.css("company").text.should == company_id
        login_doc.css("user").text.should == username
        login_doc.css("password").text.should == password
      end
    end
  end
end

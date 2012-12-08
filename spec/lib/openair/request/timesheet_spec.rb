require "spec_helper"
require "time"

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
    subject { OpenAir::Request::Timesheet.request(request_options, auth_options, query_options) }

    context "without options" do
      let(:query_options) { {} }

      it "builds a timesheet read request" do
        subject.should have_request_with_headers_with_key(api_key)
        subject.should have_request_login
        subject.css("request > Read[type='Timesheet'][method='all'][limit]").should be_one
      end
    end

    context "with query options" do
      context "for specific users" do
        let(:query_options) do
          {users: [111, 999]}
        end

        it "builds a request with user filter" do
          subject.should have_request_with_headers_with_key(api_key)
          subject.should have_request_login
          subject.css("request > Read[type='Timesheet'][method='user'][limit]").should be_one
          subject.css("request > Read > User > id").size.should == 2
        end
      end

      context "for a specific date range" do
        let(:query_options) do
          {
            older_than: Time.parse("2011-1-1 8:59:01 UTC"),
            newer_than: Time.parse("2012-2-29 23:59:58 UTC")
          }
        end

        it "builds a request with both date filters" do
          subject.should have_request_with_headers_with_key(api_key)
          subject.should have_request_login

          subject.css("request > Read[type='Timesheet'][method='all'][limit][filter='newer-than,older-than'][field='starts,starts']").should be_one

          subject.css("request > Read > Date:nth-child(1)").tap do |date_doc|
            date_doc.css("year").text.should == "2012"
            date_doc.css("month").text.should == "2"
            date_doc.css("day").text.should == "29"
            date_doc.css("hour").text.should == "23"
            date_doc.css("minute").text.should == "59"
            date_doc.css("second").text.should == "58"
          end
          subject.css("request > Read > Date:nth-child(2)").tap do |date_doc|
            date_doc.css("year").text.should == "2011"
            date_doc.css("month").text.should == "1"
            date_doc.css("day").text.should == "1"
            date_doc.css("hour").text.should == "8"
            date_doc.css("minute").text.should == "59"
            date_doc.css("second").text.should == "1"
          end
        end
      end

      context "for older-than date only" do
        let(:query_options) do
          {
            older_than: Time.parse("2012-2-1")
          }
        end

        it "builds a request with only one date filter" do
          subject.should have_request_with_headers_with_key(api_key)
          subject.should have_request_login

          subject.css("request > Read[type='Timesheet'][method='all'][limit][filter='older-than'][field='starts']").should be_one
          subject.css("request > Read > Date").size.should == 1
        end
      end

      context "for newer-than date only" do
        let(:query_options) do
          {
            newer_than: Time.parse("2012-2-1")
          }
        end

        it "builds a request with only one date filter" do
          subject.should have_request_with_headers_with_key(api_key)
          subject.should have_request_login

          subject.css("request > Read[type='Timesheet'][method='all'][limit][filter='newer-than'][field='starts']").should be_one
          subject.css("request > Read > Date").size.should == 1
        end
      end

      context "to filter by users and a date range" do
        let(:query_options) do
          {
            users: [123, 987],
            older_than: Time.parse("2012-2-1"),
            newer_than: Time.parse("2012-1-1")
          }
        end

        it "builds a timesheet request with both" do
          subject.should have_request_with_headers_with_key(api_key)
          subject.should have_request_login

          subject.css("request > Read[type='Timesheet'][method='user'][limit][filter='newer-than,older-than'][field='starts,starts']").should be_one
          subject.css("request > Read > User").size.should == 2
          subject.css("request > Read > Date").size.should == 2
        end
      end
    end
  end
end

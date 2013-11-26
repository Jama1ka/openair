require 'cgi'

module OpenAir::Request
  class User
    class << self
      def request(request_options, auth_options)
        login_elements = Login.elements(auth_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }
            xml.Read(type: "User", method: "all", limit: DEFAULT_LIMIT)
          end
        end.doc
      end

      def change_password(request_options, auth_options, user_id, password)
        login_elements = Login.elements(auth_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }
            xml.Modify(type: "User") {
              xml.User {
                xml.id user_id
                xml.password password
              }
            }
          end
        end.doc
      end

      def modify(request_options, auth_options, user_data)
        login_elements = Login.elements(auth_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }
            xml.Modify(type: "User", enable_custom: "1") {
              xml.User {
                hash_each(user_data, xml)
              }
            }
          end
        end.doc
      end

      def create(request_options, auth_options, user_data)
        login_elements = Login.elements(auth_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }
            xml.CreateUser(enable_custom: "1") {
              xml.Company {
                xml.nickname "Synapse"
              }
              xml.User {
                hash_each(user_data, xml)
              }
            }
          end
        end.doc
      end

      def get_target_utilization(request_options, auth_options, field_name, value)
        login_elements = Login.elements(auth_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }
            xml.Read(type: "TargetUtilization", enable_custom: "1", method: "equal to", limit: "1000") {
              xml.TargetUtilization {
                xml.send(field_name, value)
              }
            }
          end
        end.doc
      end

      # util_data = {:user_id=>161, :start_date=> { Date: { month: "11", year: "2013", day: "25"}}, :percentage=>"79.00"}

      def set_target_utilization(request_options, auth_options, utilization_data)
        login_elements = Login.elements(auth_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }
            xml.Add(type: "TargetUtilization") {
              xml.TargetUtilization {
                hash_each(utilization_data, xml)
              }
            }
          end
        end.doc
      end

      def find(request_options, auth_options, field_name, value)
        login_elements = Login.elements(auth_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }
            xml.Read(type: "User", enable_custom: "1", method: "equal to", limit: "1") {
              xml.User {
                xml.send(field_name, value)
              }
            }
          end
        end.doc
      end

      def hash_each(data, xml)
        data.each do |field,value|
          if value.instance_of? Hash
            xml.send(field) do
              hash_each(value, xml)
            end
          else
            xml.send(field, CGI.escapeHTML(value.to_s))
          end
        end
      end
    end
  end
end


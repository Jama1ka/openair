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

      def find_by_netsuite_id(request_options, auth_options, netsuite_id)
        login_elements = Login.elements(auth_options)

        Nokogiri::XML::Builder.new do |xml|
          xml.request(request_options) do
            xml.Auth { xml.parent << login_elements }
            xml.Read(type: "User", enable_custom: "1", method: "equal to", limit: "1") {
              xml.User {
                xml.netsuite_user_id__c netsuite_id
              }
            }
          end
        end.doc
      end
    end
  end
end


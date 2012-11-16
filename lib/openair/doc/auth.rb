class OpenAir::Doc::Auth
  class << self
    def login(options)
      Nokogiri::XML::Builder.new do |xml|
        xml.Login do
          xml.company(options[:company_id])
          xml.user(options[:username])
          xml.password(options[:password])
        end
      end.doc
    end
  end
end


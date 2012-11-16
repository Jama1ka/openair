class OpenAir::Request::Utility
  class << self
    def time_request(request_options)
      Nokogiri::XML::Builder.new do |xml|
        xml.request(request_options) do
          xml.Time
        end
      end.doc
    end
  end
end


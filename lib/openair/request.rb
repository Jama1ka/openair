module OpenAir::Request
  DEFAULT_LIMIT = "300"
end

Dir[File.dirname(__FILE__) + "/request/**/*.rb"].each {|f| require f}

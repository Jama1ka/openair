module OpenAir::Request
  DEFAULT_LIMIT = "10"
end

Dir[File.dirname(__FILE__) + "/request/**/*.rb"].each {|f| require f}

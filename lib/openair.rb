require "rubygems"
require "typhoeus"
require "nokogiri"
require "nori"
require 'openair/errors'
require 'openair/version'

module OpenAir
  autoload :Configuration, 'openair/configuration'
  autoload :Client, 'openair/client'
  autoload :Request, 'openair/request'

  def self.configure(&block)
    OpenAir::Configuration.instance_eval(&block)
  end
end

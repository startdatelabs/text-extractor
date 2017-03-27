require "text_extractor/version"
require "text_extractor/base"
require "text_extractor/pdf"
require "text_extractor/png"
require "docsplit"
require "ruby_tika_app"
require 'doc_ripper'

module TextExtractor
  class Configuration
    attr_accessor :allowed_extensions, :min_text_length

    def initialize
      @allowed_extensions = [/doc\Z/i, /docx\Z/i, /html\Z/i, /odt\Z/i, /xml\Z/i, /pub\Z/i, /epub\Z/i, /rtf\Z/i, /pdf\Z/i, /txt\Z/i, /wps\Z/i]
      @min_text_length = 150
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  include TextExtractor::Base
end

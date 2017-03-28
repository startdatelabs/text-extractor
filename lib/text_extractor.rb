require 'text_extractor/version'
require 'text_extractor/base'
require 'text_extractor/configuration'

module TextExtractor
  class << self
    attr_writer :configuration

    def extract(file_path)
      Base.new(file_path).extract
    end
  end

  def self.configuration
    @configuration ||= TextExtractor::Configuration.new
  end

  def self.reset
    @configuration = TextExtractor::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end

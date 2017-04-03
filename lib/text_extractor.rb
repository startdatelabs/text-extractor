require 'active_support'
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

  def self.root
    File.dirname __dir__
  end
end

Dir[File.join(TextExtractor.root, 'lib', 'tasks', '**', '*.rake')].each { |file| load file }

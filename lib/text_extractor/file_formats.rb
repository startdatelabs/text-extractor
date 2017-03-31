Dir["#{ File.dirname(__FILE__) }/formats/*.rb"].each {|file| require file }

module TextExtractor
  module FileFormats
    extend ActiveSupport::Concern

    include TextExtractor::Formats::Pdf
    include TextExtractor::Formats::Image
    include TextExtractor::Formats::Txt
    include TextExtractor::Formats::Doc
    include TextExtractor::Formats::Docx
    include TextExtractor::Formats::Rtf
    include TextExtractor::Formats::Odt
    include TextExtractor::Formats::Html
    include TextExtractor::Formats::Pages
  end
end

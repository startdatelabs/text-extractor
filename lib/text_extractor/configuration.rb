module TextExtractor
  class Configuration
    attr_accessor :allowed_extensions, :min_text_length

    def initialize
      @allowed_extensions = [
        /doc\Z/i, /docx\Z/i,
        /htm\Z/i, /html\Z/i,
        /odt\Z/i,
        /xml\Z/i,
        /pub\Z/i, /epub\Z/i,
        /rtf\Z/i,
        /pdf\Z/i,
        /txt\Z/i,
        /wps\Z/i,
        # /wpd\Z/i,
        # /ppt\Z/i,
        # /pptx\Z/i,
        /png\Z/i, /jpg\Z/i, /jpeg\Z/i,
        /pages\Z/i
      ]
      @min_text_length = 150
    end
  end
end

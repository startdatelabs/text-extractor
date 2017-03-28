module TextExtractor
  module Txt
    extend ActiveSupport::Concern

    def extract_text_from_txt(original_file_path)
      text = nil
      if ::File.exist?(original_file_path)
        text = File.read(original_file_path).force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
        text = escape_text(text)
      end

      text
    end
  end
end

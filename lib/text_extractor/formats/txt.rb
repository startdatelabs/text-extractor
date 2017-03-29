module TextExtractor
  module Txt
    extend ActiveSupport::Concern

    def extract_text_from_txt(original_file_path)
      text = nil
      if ::File.exist?(original_file_path)
        text = File.read(original_file_path)
        text = escape_text(text)
      end

      text
    end
  end
end

module TextExtractor
  module Txt
    extend ActiveSupport::Concern

    def extract_from_txt(original_file_path, with_delete = true)
      text = nil
      if ::File.exist?(original_file_path)
        text = File.read(original_file_path).force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
        File.delete(original_file_path) if with_delete
        text = escape_text(text)
      end

      text
    end
  end
end

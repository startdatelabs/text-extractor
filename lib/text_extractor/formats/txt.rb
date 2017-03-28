module TextExtractor
  module Txt
    extend ActiveSupport::Concern

    def extract_from_txt(_file_path)
      text = nil
      if ::File.exists?(_file_path)
        text = File.read(_file_path).force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
        File.delete(_file_path)
        text = escape_text(text)
      end

      text
    end
  end
end

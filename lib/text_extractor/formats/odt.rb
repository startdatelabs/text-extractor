# -*- encoding : utf-8 -*-
module TextExtractor
  module Odt
    extend ActiveSupport::Concern

    def extract_text_from_odt(original_file_path)
      command = %{odt2txt #{ to_shell(original_file_path) } --output=#{ to_shell(text_file_path) }}
      run_shell(command)
      text = extract_text_from_txt(text_file_path)

      if text.include?('[-- Image: Picture')
        extract_text_with_docsplit(original_file_path)
      else
        text
      end
    end
  end
end

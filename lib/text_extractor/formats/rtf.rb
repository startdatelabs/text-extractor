# -*- encoding : utf-8 -*-
module TextExtractor
  module Rtf
    extend ActiveSupport::Concern

    def extract_text_from_rtf(original_file_path)
      command = %{unrtf --text --nopict #{ to_shell(original_file_path) } | awk 'NR == 1, /-----------------/ { next } { print }' > #{ to_shell(text_file_path) }}
      run_shell(command)
      text = extract_from_txt(text_file_path)

      if text.include?('picture data found')
        extract_text_with_docsplit(original_file_path)
      else
        text
      end
    end
  end
end
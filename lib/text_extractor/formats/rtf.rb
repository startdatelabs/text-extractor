# -*- encoding : utf-8 -*-
module TextExtractor
  module Rtf
    extend ActiveSupport::Concern

    def extract_text_from_rtf(_file_path)
      command = %{unrtf --text --nopict #{ to_shell(_file_path) } | awk 'NR == 1, /-----------------/ { next } { print }' > #{ to_shell(text_file_path) }}
      result = ::POSIX::Spawn::Child.new(command, timeout: 20, pgroup_kill: true)
      text = extract_from_txt(text_file_path)

      if text.include?('picture data found')
        extract_text_with_docsplit(_file_path)
      else
        text
      end
    end
  end
end

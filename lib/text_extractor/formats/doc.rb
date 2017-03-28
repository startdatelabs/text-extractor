# -*- encoding : utf-8 -*-
module TextExtractor
  module Doc
    extend ActiveSupport::Concern
    def extract_text_from_doc(_file_path)
      result = ::POSIX::Spawn::Child.new(%{antiword #{ to_shell(_file_path) } > #{ to_shell(text_file_path) }}, timeout: 20, pgroup_kill: true)
      text = extract_from_txt(text_file_path)

      if text.length < TextExtractor.configuration.min_text_length && text.include?('[pic]')
        extract_text_with_docsplit(_file_path)
      else
        text
      end
    end
  end
end


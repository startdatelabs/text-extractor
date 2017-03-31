# -*- encoding : utf-8 -*-
module TextExtractor
  module Formats
    module Doc
      extend ActiveSupport::Concern

      def extract_text_from_doc(original_file_path)
        run_shell(%{antiword #{ to_shell(original_file_path) } > #{ to_shell(text_file_path) }})
        text = extract_text_from_txt(text_file_path)

        if text.length < TextExtractor.configuration.min_text_length && text.include?('[pic]')
          extract_text_with_docsplit(original_file_path)
        else
          text
        end
      end

      def self.formats
        {
          '.doc' => 'doc'
        }
      end
    end
  end
end


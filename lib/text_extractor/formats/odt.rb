# -*- encoding : utf-8 -*-
module TextExtractor
  module Formats
    module Odt
      extend ActiveSupport::Concern

      def extract_text_from_odt(original_file_path)
        command = %{odt2txt #{ to_shell(original_file_path) } --output=#{ to_shell(text_file_path) }}
        run_shell(command)
        text = extract_text_from_txt(text_file_path)

        if text.length < TextExtractor.configuration.min_text_length && text.include?('[-- Image: Picture')
          extract_text_with_docsplit(original_file_path)
        else
          text
        end
      end

      def self.formats
        {
          '.odt' => 'odt'
        }
      end
    end
  end
end

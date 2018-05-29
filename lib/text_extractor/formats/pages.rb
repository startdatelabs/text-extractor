# -*- encoding : utf-8 -*-
module TextExtractor
  module Formats
    module Pages
      extend ActiveSupport::Concern

      def extract_text_from_pages(original_file_path)
        self.text_file_path = original_file_path.gsub(/\.pages/, '.txt')
        command = %{soffice --headless --convert-to txt:Text #{ to_shell(original_file_path) } --outdir #{ to_shell(File.dirname(self.text_file_path)) } }

        run_shell(command)
        text = extract_text_from_txt(text_file_path)
        if text.length < TextExtractor.configuration.min_text_length
          text = extract_text_with_docsplit(original_file_path)
        end

        text
      end

      def self.formats
        {
          '.pages' => 'pages'
        }
      end
    end
  end
end

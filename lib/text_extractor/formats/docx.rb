# -*- encoding : utf-8 -*-
module TextExtractor
  module Formats
    module Docx
      extend ActiveSupport::Concern

      def extract_text_from_docx(original_file_path)
        self.text_file_path = original_file_path.gsub(/\.docx/, '.txt')
        # command = %{#{ TextExtractor.root }/ext/docx2txt.sh #{ to_shell(original_file_path) }}
        command = %{soffice --headless --convert-to txt:Text #{ to_shell(original_file_path) } --outdir #{ to_shell(File.dirname(self.text_file_path)) } }

        run_shell(command)
        text = extract_text_from_txt(text_file_path)
        if text.length < TextExtractor.configuration.min_text_length && docx_has_image?(original_file_path)
          text = extract_text_with_docsplit(original_file_path)
        end

        text
      end

      def docx_has_image?(original_file_path)
        output_folder = temp_folder_for_parsed
        run_shell("unzip '#{ original_file_path }' -d #{ output_folder } > /dev/null")
        has_image = File.directory?("#{ output_folder }/word/media/")
        ::FileUtils.rm_rf(output_folder)
        has_image
      end

      def self.formats
        {
          '.docx' => 'docx'
        }
      end
    end
  end
end


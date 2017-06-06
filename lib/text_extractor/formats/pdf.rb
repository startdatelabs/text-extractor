# -*- encoding : utf-8 -*-
module TextExtractor
  module Formats
    module Pdf
      extend ActiveSupport::Concern

      def extract_text_from_pdf(original_file_path)
        parsed_text = extract_as_text_from_pdf(original_file_path)

        if parsed_text.length < TextExtractor.configuration.min_text_length
          # png_pathes = extract_images(original_file_path)
          png_pathes = extract_to_ppm_from_pdf(original_file_path)
          parsed_text = extract_text_from_image(png_pathes)
        end

        parsed_text
      end

      private
      def extract_as_text_from_pdf(original_file_path)
        run_shell(%{pdftotext -enc UTF-8 #{ to_shell(original_file_path) } #{ to_shell(text_file_path) }})

        extract_text_from_txt(text_file_path)
      end

      def extract_to_ppm_from_pdf(original_file_path)
        output_folder = temp_folder_for_parsed
        run_shell(%{pdftoppm -r 300 -gray -f 5 #{ to_shell(original_file_path) } #{ File.join(output_folder, 'temp_file') }})
        ::Dir["#{ output_folder }/*"]
      end

      def self.formats
        {
          '.pdf' => 'pdf'
        }
      end

      def self.is_pdf_file?(file_path)
        File.open(file_path, 'rb',&:readline) =~ /\A\%PDF-\d+(\.\d+)?/
      end

=begin
      def get_count_pages(_file_path)
        pdfinfo = run_shell(%{pdfinfo #{_file_path}})
        pdfinfo.out =~ /Pages:\s+(\d+)/i
        $1.to_i
      end

      def get_page_size(_file_path)
        pdfinfo = run_shell(%{pdfinfo #{_file_path}})
        pdfinfo.out =~ /Page size:\s+(\d+)\sx\s(\d+)/i
        [$1.to_i, $2.to_i]
      end

      def extract_images(_file_path)
        output_file = temp_folder_for_parsed
        run_shell(%{pdfimages #{ _file_path } #{ output_file } })
        ::Dir["#{output_file}*"]
      end
=end
    end
  end
end

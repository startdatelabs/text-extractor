# -*- encoding : utf-8 -*-
module TextExtractor
  module Pdf
    extend ActiveSupport::Concern

    def extract_text_from_pdf(original_file_path)
      parsed_text = extract_as_text_from_pdf(original_file_path)

      if parsed_text.length < TextExtractor.configuration.min_text_length
        # png_pathes = extract_images(original_file_path)
        png_pathes = extract_to_ppm_from_pdf(original_file_path)
        parsed_text = extract_text_from_png(png_pathes)
      end

      parsed_text
    end

private
    def extract_as_text_from_pdf(original_file_path)
      run_shell(%{pdftotext #{ to_shell(original_file_path) } #{ to_shell(text_file_path) }})

      extract_from_txt(text_file_path)
    end

    def extract_to_ppm_from_pdf(original_file_path)
      output_folder = "./tmp/#{ SecureRandom.hex(10) }"
      run_shell(%{pdftoppm -r 300 -gray #{ to_shell(original_file_path) } #{ output_folder }})
      ::Dir["#{ output_folder }*"]
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
      output_file = "./tmp/#{ SecureRandom.hex(10) }"
      run_shell(%{pdfimages #{ _file_path } #{ output_file } })
      ::Dir["#{output_file}*"]
    end
=end
  end
end

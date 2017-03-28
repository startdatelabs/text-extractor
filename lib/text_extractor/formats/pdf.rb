# -*- encoding : utf-8 -*-
module TextExtractor
  module Pdf
    extend ActiveSupport::Concern

    def extract_text_from_pdf(_file_path)
      parsed_text = extract_as_text_from_pdf(_file_path)

      if parsed_text.length < TextExtractor.configuration.min_text_length
        # png_pathes = extract_images(_file_path)
        png_pathes = extract_to_ppm_from_pdf(_file_path)
        parsed_text = extract_text_from_png(png_pathes)
      end

      parsed_text
    end

private
    def extract_as_text_from_pdf(_file_path)
      parsed_text = ''

      result = ::POSIX::Spawn::Child.new(%{pdftotext #{ to_shell(_file_path) } #{ to_shell(text_file_path) }}, timeout: 20, pgroup_kill: true)

      parsed_text = extract_from_txt(text_file_path)
    end

    def extract_to_ppm_from_pdf(_file_path)
      output_folder = "./tmp/#{ SecureRandom.hex(10) }"
      result = ::POSIX::Spawn::Child.new(%{pdftoppm -r 300 -gray #{ to_shell(_file_path) } #{ output_folder }}, timeout: 20, pgroup_kill: true)
      ::Dir["#{ output_folder }*"]
    end

=begin
    def get_count_pages(_file_path)
      pdfinfo = ::POSIX::Spawn::Child.new(%{pdfinfo #{_file_path}}, timeout: 15, pgroup_kill: true)
      pdfinfo.out =~ /Pages:\s+(\d+)/i
      $1.to_i
    end

    def get_page_size(_file_path)
      pdfinfo = ::POSIX::Spawn::Child.new(%{pdfinfo #{_file_path}}, timeout: 15, pgroup_kill: true)
      pdfinfo.out =~ /Page size:\s+(\d+)\sx\s(\d+)/i
      [$1.to_i, $2.to_i]
    end

    def extract_images(_file_path)
      output_file = "./tmp/#{ SecureRandom.hex(10) }"
      result = ::POSIX::Spawn::Child.new(%{pdfimages #{ _file_path } #{ output_file } }, timeout: 40, pgroup_kill: true)
      ::Dir["#{output_file}*"]
    end
=end
  end
end

# -*- encoding : utf-8 -*-
require 'posix/spawn'
module TextExtractor
  class Pdf
    class << self
      def extract_text(file_path)
        parsed_text = extract_as_text(file_path)

        if parsed_text.length < TextExtractor.configuration.min_text_length
          # png_pathes = extract_images(file_path)
          png_pathes = extract_to_ppm(file_path)
          parsed_text = TextExtractor::PNG.extract_text(png_pathes)
        end

        parsed_text
      end

      def get_count_pages(file_path)
        pdfinfo = ::POSIX::Spawn::Child.new(%{pdfinfo #{file_path}}, timeout: 15, pgroup_kill: true)
        pdfinfo.out =~ /Pages:\s+(\d+)/i
        $1.to_i
      end

      def get_page_size(file_path)
        pdfinfo = ::POSIX::Spawn::Child.new(%{pdfinfo #{file_path}}, timeout: 15, pgroup_kill: true)
        pdfinfo.out =~ /Page size:\s+(\d+)\sx\s(\d+)/i
        [$1.to_i, $2.to_i]
      end

      def extract_as_text(file_path)
        parsed_text = ''

        output_file = "./tmp/#{ SecureRandom.hex(10) }.txt"
        result = ::POSIX::Spawn::Child.new(%{pdftotext #{ file_path } #{ output_file }}, timeout: 20, pgroup_kill: true)

        if ::File.exists?(output_file)
          text = File.read(output_file)
          File.delete(output_file)
          parsed_text = TextExtractor.escape_text(text)
        end
        parsed_text
      end

      def extract_images(file_path)
        output_file = "./tmp/#{ SecureRandom.hex(10) }"
        result = ::POSIX::Spawn::Child.new(%{pdfimages #{ file_path } #{ output_file } }, timeout: 40, pgroup_kill: true)
        ::Dir["#{output_file}*"]
      end

      def extract_to_ppm(file_path)
        output_file = "./tmp/#{ SecureRandom.hex(10) }"
        result = ::POSIX::Spawn::Child.new(%{pdftoppm -r 300 -gray #{ file_path } #{ output_file }}, timeout: 20, pgroup_kill: true)
        ::Dir["#{output_file}*"]
      end
    end
  end
end

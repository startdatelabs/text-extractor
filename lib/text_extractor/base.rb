# -*- encoding : utf-8 -*-
require 'posix/spawn'
module TextExtractor
  module Base
    extend ActiveSupport::Concern

    DOC_SPLIT_TIMEOUT = 30.seconds
    DOCUMENT = 'document'
    PDF = 'pdf'
    TXT = 'txt'
    IMAGE = 'image'
    DOC = 'doc'
    DOCX = 'docx'
    class NotSupportExtensionException < Exception; end
    class FileEmpty < Exception; end

    class_methods do
      def extract(file_path, owner = nil)
        raise NotSupportExtensionException.new unless TextExtractor.configuration.allowed_extensions.any? { |a| a =~ ::File.extname(file_path).downcase }

        file_path = fix_file_name(file_path)
        file_type = detect_file_type(file_path)

        parsed_text = extract_text_by_type(file_path, file_type)
        parsed_text = TextExtractor.escape_text(parsed_text)
        raise FileEmpty if TextExtractor.empty_result?(parsed_text)
        parsed_text
      end

      def fix_file_name(file_path)
        original_file_name = ::File.basename(file_path)
        original_file_path = file_path
        if original_file_name =~ /\(|\)|\s/i
          file_path = ::File.join(Pathname.new(file_path).dirname, original_file_name.gsub(/\(|\)|\s/i, ''))
          ::File.rename(original_file_path, file_path)
        end

        file_path
      end

      def detect_file_type(file_path)
        extname = ::File.extname(file_path).downcase

        case extname
        when /.pdf/i
          PDF
        when /.png/i
          IMAGE
        when /.jpg/i
          IMAGE
        when /.jpeg/i
          IMAGE
        when /.doc/i
          DOC
        when /.docx/i
          DOCX
        when /.txt/i
          line = File.readlines(file_path).first
          escaped_line = TextExtractor.escape_text(line)
          if escaped_line =~ /pdf/i
            PDF
          else
            TXT
          end
        else
          DOCUMENT
        end
      end

      def extract_text_by_type(file_path, file_type)
        parsed_text = ''

        parsed_text = case file_type
        when PDF
          TextExtractor::Pdf.extract_text(file_path)
        when IMAGE
          TextExtractor::Png.extract_text(file_path)
        when DOC
          ::DocRipper::rip(file_path)
        when DOCX
          ::DocRipper::rip(file_path)
        when TXT
          ::File.read(file_path)
        else
          begin
            extract_text_with_tika_app(file_path)
          rescue Exception
            extract_text_with_docsplit(file_path)
          end
        end

        parsed_text
      end

      def extract_text_with_tika_app(file_path)
        parsed_text = ::RubyTikaApp.new(file_path).to_text
        parsed_text
      end

      def extract_text_with_docsplit(file_path)
        tmp_dir = "tmp/#{ SecureRandom.hex(10) }"

        ::Timeout::timeout(DOC_SPLIT_TIMEOUT) do
          ::Docsplit.extract_text(file_path, output: tmp_dir)
        end

        text = IO.read(Dir["#{ tmp_dir }/*.txt"].first)

        ::FileUtils.rm_rf(tmp_dir)

        text
      end

      def empty_result?(text)
        text.gsub(/\W/, '').empty?
      end

      def escape_text(text)
        text.without_non_utf8
      end
    end
  end
end

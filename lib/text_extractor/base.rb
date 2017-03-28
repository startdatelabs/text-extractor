# -*- encoding : utf-8 -*-
require 'posix/spawn'
require 'docsplit'
require 'ruby_tika_app'
require 'text_extractor/helpers'
require 'text_extractor/file_types'
require 'text_extractor/formats/doc'
require 'text_extractor/formats/docx'
require 'text_extractor/formats/pdf'
require 'text_extractor/formats/png'
require 'text_extractor/formats/txt'
require 'text_extractor/formats/rtf'
require 'text_extractor/formats/odt'

module TextExtractor
  class NotSupportExtensionException < Exception; end
  class FileEmpty < Exception; end

  class Base
    include TextExtractor::Helpers
    include TextExtractor::FileTypes
    include TextExtractor::Pdf
    include TextExtractor::Png
    include TextExtractor::Txt
    include TextExtractor::Doc
    include TextExtractor::Docx
    include TextExtractor::Rtf
    include TextExtractor::Odt

    DOC_SPLIT_TIMEOUT = 30.seconds

    attr_accessor :file_path, :text_file_path

    def initialize(_file_path)
      _file_path = fix_file_name(_file_path)
      @file_path      = _file_path
      @text_file_path = "#{ SecureRandom.hex(10) }.txt"
    end

    def extract
      raise TextExtractor::NotSupportExtensionException.new unless TextExtractor.configuration.allowed_extensions.any? { |a| a =~ ::File.extname(file_path).downcase }

      file_type = detect_file_type(file_path)

      parsed_text = extract_by_type(file_path, file_type)
      parsed_text = escape_text(parsed_text)
      raise TextExtractor::FileEmpty if empty_result?(parsed_text)
      parsed_text
    end

    def extract_by_type(file_path, file_type)
      parsed_text = case file_type
      when PDF
        extract_text_from_pdf(file_path)
      when IMAGE
        extract_text_from_png(file_path)
      when DOC
        extract_text_from_doc(file_path)
      when DOCX
        extract_text_from_docx(file_path)
      when RTF
        extract_text_from_rtf(file_path)
      when ODT
        extract_text_from_odt(file_path)
      when TXT
        extract_from_txt(file_path, false)
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

      text = Dir["#{ tmp_dir }/*.txt"].map do |path|
        extract_from_txt(path)
      end

      ::FileUtils.rm_rf(tmp_dir)

      text.join('')
    end
  end
end
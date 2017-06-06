# -*- encoding : utf-8 -*-
require 'posix/spawn'
require 'docsplit'
require 'text_extractor/helpers'
require 'text_extractor/file_formats'


module TextExtractor
  class NotSupportExtensionException < Exception; end
  class FileEmpty < Exception; end
  class NotInstalledExtension < Exception; end
  class ExceptionInExtension < Exception; end

  SUCESS_STATUS = 200                   # 200 success
  WRONG_PARAMS_STATUS = 400             # 400 wrong params
  NOT_SUPPORT_EXTNAME = 512             # 512 Not support extname
  FILE_EMPTY_STATUS = 513               # 513 File empty
  NOT_INSTALLED_EXTENSION_STATUS = 514  # 514 Not installed extension
  UNKNOWN_ERRROR_STATUS = 515           # 515 Unknown error

  class Base
    include TextExtractor::Helpers
    include TextExtractor::FileFormats

    DOC_SPLIT_TIMEOUT = 30

    attr_accessor :file_path, :text_file_path

    def self.processing_formats
      @processing_formats ||= begin
        _processing_formats = {}
        modules = TextExtractor::Base.included_modules.select { |m| m.to_s.include?('::Formats::') }
        modules.each do |m|
          _processing_formats.merge!(m.formats)
        end
        _processing_formats
      end
    end

    def initialize(original_file_path)
      temp_file = File.join(temp_folder, ::File.basename(original_file_path))
      FileUtils.cp(original_file_path, temp_file)

      temp_file = fix_file_name(temp_file)
      @file_path      = temp_file
      @text_file_path = temp_txt_file
    end

    def extract
      raise TextExtractor::NotSupportExtensionException.new unless TextExtractor.configuration.allowed_extensions.any? { |a| a =~ ::File.extname(file_path).downcase }

      parsed_text = extract_by_type
      parsed_text = escape_text(parsed_text)
      parsed_text = remove_extra_spaces(parsed_text)
      raise TextExtractor::FileEmpty if empty_result?(parsed_text)

      # text_for_validate = remove_extra_spaces(parsed_text)
      # raise TextExtractor::FileEmpty if empty_result?(text_for_validate)
      parsed_text
    ensure
      ::FileUtils.rm_rf(temp_folder)
    end

    private

    def extract_by_type
      extname = ::File.extname(file_path).downcase
      postfix_of_method = TextExtractor::Base.processing_formats[extname]

      parsed_text = if TextExtractor::Formats::Pdf.is_pdf_file?(file_path)
        extract_text_from_pdf(file_path)
      elsif postfix_of_method
        send(:"extract_text_from_#{ postfix_of_method }", file_path)
      else
        extract_text_with_docsplit(file_path)
      end

      parsed_text
    end

    def extract_text_with_docsplit(file_path)
      tmp_dir = temp_folder_for_parsed

      ::Timeout::timeout(DOC_SPLIT_TIMEOUT) do
        ::Docsplit.extract_text(file_path, output: tmp_dir)
      end

      text = Dir["#{ tmp_dir }/*.txt"].map do |path|
        extract_text_from_txt(path)
      end

      ::FileUtils.rm_rf(tmp_dir)

      text.join('')
    end
  end
end

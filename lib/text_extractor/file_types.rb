module TextExtractor
  module FileTypes
    extend ActiveSupport::Concern

    DOCUMENT = 'document'
    PDF = 'pdf'
    TXT = 'txt'
    PNG = 'png'
    DOC = 'doc'
    DOCX = 'docx'
    RTF = 'rtf'
    ODT = 'odt'

    COMMON_TYPES = [PDF, PNG, DOC, DOCX, RTF, ODT, TXT]

    def detect_file_type(original_file_path)
      extname = ::File.extname(original_file_path).downcase

      case extname
      when /.pdf/i
        PDF
      when /.png/i, /.jpg/i, /.jpeg/i
        PNG
      when /.docx/i
        DOCX
      when /.doc/i
        DOC
      when /.rtf/i
        RTF
      when /.odt/i
        ODT
      when /.txt/i
        line = File.readlines(original_file_path).first
        escaped_line = escape_text(line)
        if escaped_line =~ /pdf/i
          PDF
        else
          TXT
        end
      else
        DOCUMENT
      end
    end
  end
end

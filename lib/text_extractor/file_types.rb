module TextExtractor
  module FileTypes
    extend ActiveSupport::Concern

    DOCUMENT = 'document'
    PDF = 'pdf'
    TXT = 'txt'
    IMAGE = 'image'
    DOC = 'doc'
    DOCX = 'docx'
    RTF = 'rtf'

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
      when /.docx/i
        DOCX
      when /.doc/i
        DOC
      when /.rtf/i
        RTF
      when /.odt/i
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
  end
end

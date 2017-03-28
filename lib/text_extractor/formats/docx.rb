# -*- encoding : utf-8 -*-
module TextExtractor
  module Docx
    extend ActiveSupport::Concern
    def extract_text_from_docx(original_file_path)
      if docx_has_image?(original_file_path)
        extract_text_with_docsplit(original_file_path)
      else
        command = %{unzip -p #{ to_shell(original_file_path) } | grep '<w:t' | sed 's/<[^<]*>//g' | grep -v '^[[:space:]]*$' > #{ to_shell(text_file_path) } }
        run_shell(command)
        extract_from_txt(text_file_path)
      end
    end

    def docx_has_image?(original_file_path)
      output_folder = "./tmp/#{ SecureRandom.hex(10) }"
      run_shell("unzip '#{ original_file_path }' -d #{ output_folder } > /dev/null")

      media_folder = "#{ output_folder }/word/media/"
      if File.directory?(media_folder)
        ::FileUtils.rm_rf(media_folder)
        true
      else
        false
      end
    end
  end
end


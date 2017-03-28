# -*- encoding : utf-8 -*-
module TextExtractor
  module Docx
    extend ActiveSupport::Concern
    def extract_text_from_docx(_file_path)
      if docx_has_image?(_file_path)
        extract_text_with_docsplit(_file_path)
      else
        command = %{unzip -p #{ to_shell(_file_path) } | grep '<w:t' | sed 's/<[^<]*>//g' | grep -v '^[[:space:]]*$' > #{ to_shell(text_file_path) } }
        result = ::POSIX::Spawn::Child.new(command, timeout: 20, pgroup_kill: true)
        extract_from_txt(text_file_path)
      end
    end

    def docx_has_image?(_file_path)
      output_folder = "./tmp/#{ SecureRandom.hex(10) }"
      ::POSIX::Spawn::Child.new("unzip '#{ _file_path }' -d #{ output_folder } > /dev/null")
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


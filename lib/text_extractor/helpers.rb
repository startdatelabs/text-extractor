module TextExtractor
  module Helpers
    extend ActiveSupport::Concern

    def fix_file_name(file_path)
      original_file_name = ::File.basename(file_path)
      original_file_path = file_path
      if original_file_name =~ /\(|\)|\s/i
        file_path = ::File.join(Pathname.new(file_path).dirname, original_file_name.gsub(/\(|\)|\s/i, ''))
        ::File.rename(original_file_path, file_path)
      end

      file_path
    end

    def empty_result?(text)
      text.gsub(/\W/, '').empty?
    end

    def escape_text(text)
      text.without_non_utf8
    end

    def to_shell(file_path)
      Shellwords.escape(file_path)
    end

    def run_shell(command)
      ::POSIX::Spawn::Child.new(command, timeout: 20, pgroup_kill: true)
    end

    def temp_folder
      @temp_folder ||= begin
        path = "./tmp/temp_resumes"
        FileUtils.mkdir_p(path)
        path
      end
    end

    def temp_folder_for_parsed
      folder = File.join(temp_folder, SecureRandom.hex(10))
      temp_folders << folder
      folder
    end

    def temp_txt_file
      File.join(temp_folder, %{#{ SecureRandom.hex(10) }.txt})
    end
  end
end

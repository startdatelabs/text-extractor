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
      string_blank?(text&.gsub(/\W/, ''))
    end

    def remove_extra_spaces(text)
      text&.gsub(/[[:space:]]+/, ' ')&.strip
    end

    def escape_text(text)
      without_non_utf8(text)
    end

    def to_shell(file_path)
      Shellwords.escape(file_path)
    end

    def run_shell(command)
      result = ::POSIX::Spawn::Child.new(command, timeout: 20, pgroup_kill: true)
      if result.err =~ /command not found/i || result.err =~ /No such file or directory/i || result.err =~ /currently not installed/i
        raise TextExtractor::NotInstalledExtension.new(result.err)
      end
      result
    end

    def temp_folder
      @temp_folder ||= begin
        path = "./tmp/temp_resumes"
        path = File.join(path, SecureRandom.hex(10))
        FileUtils.mkdir_p(path)
        path
      end
    end

    def temp_folder_for_parsed
      folder = File.join(temp_folder, SecureRandom.hex(10))
      FileUtils.mkdir_p(folder)
      folder
    end

    def temp_txt_file
      File.join(temp_folder, %{#{ SecureRandom.hex(10) }.txt})
    end

    def without_non_utf8(text, replacement = '')
      text&.encode('UTF-8', invalid: :replace, undef: :replace, replace: replacement)
    end

    def string_blank?(text)
      text.nil? || text.empty?
    end
  end
end

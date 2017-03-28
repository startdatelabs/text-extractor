# -*- encoding : utf-8 -*-
module TextExtractor
  module Png
    extend ActiveSupport::Concern

    def extract_text_from_png(file_pathes)
      file_pathes = Array(file_pathes)
      result = []

      result = file_pathes.first(5).map do |_file_path|
        result = ::POSIX::Spawn::Child.new(%{tesseract #{ to_shell(_file_path) } #{ to_shell(text_file_path) } }, timeout: 40, pgroup_kill: true)
        if ::File.exists?(text_file_path) || (result.err.blank? || result.err == %{"Tesseract Open Source OCR Engine v3.04.00 with Leptonica\nWarning in pixReadMemPng: work-around: writing to a temp file\n"})
          text = extract_from_txt(text_file_path)
        end
        text
      end

      result.join('')
    ensure
      file_pathes.each do |_file_path|
        ::File.delete(_file_path)
      end
    end
  end
end



# -*- encoding : utf-8 -*-
module TextExtractor
  module Png
    extend ActiveSupport::Concern

    def extract_text_from_png(file_pathes)
      file_pathes = Array(file_pathes)
      result = []

      result = file_pathes.first(5).map do |path|
        result = run_shell(%{tesseract #{ to_shell(path) } #{ to_shell(text_file_path) } })
        if ::File.exist?(text_file_path) || (result.err.blank? || result.err == %{"Tesseract Open Source OCR Engine v3.04.00 with Leptonica\nWarning in pixReadMemPng: work-around: writing to a temp file\n"})
          text = extract_from_txt(text_file_path)
        end
        text
      end

      result.join('')
    ensure
      file_pathes.each do |path|
        ::File.delete(path)
      end
    end
  end
end



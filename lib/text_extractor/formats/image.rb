# -*- encoding : utf-8 -*-
module TextExtractor
  module Formats
    module Image
      extend ActiveSupport::Concern

      def extract_text_from_image(file_pathes)
        file_pathes = Array(file_pathes)
        result = []

        result = file_pathes.first(5).map do |path|
          result = run_shell(%{tesseract #{ to_shell(path) } #{ to_shell(text_file_path.gsub(/\.txt/, '')) } })
          if ::File.exist?(text_file_path) || (string_blank?(result.err) || result.err.include?(%{"Warning in pixReadMemPng: work-around: writing to a temp file"}))
            text = extract_text_from_txt(text_file_path)
          end
          text
        end

        result.join('')
      end

      def self.formats
        {
          '.png' => 'image',
          '.jpg' => 'image',
          '.jpeg' => 'image'
        }
      end
    end
  end
end



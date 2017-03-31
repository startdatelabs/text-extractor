# -*- encoding : utf-8 -*-
module TextExtractor
  module Formats
    module Pages
      extend ActiveSupport::Concern

      def extract_text_from_pages(original_file_path)
        extract_text_with_docsplit(original_file_path)
      end

      def self.formats
        {
          '.pages' => 'pages'
        }
      end
    end
  end
end

# -*- encoding : utf-8 -*-
module TextExtractor
  module Formats
    module Html
      extend ActiveSupport::Concern

      def extract_text_from_html(original_file_path)
        command = %{lynx --dump #{ to_shell(original_file_path) } > #{ to_shell(text_file_path) }}
        run_shell(command)
        extract_text_from_txt(text_file_path)
      end

      def self.formats
        {
          '.htm' => 'html',
          '.html' => 'html'
        }
      end
    end
  end
end

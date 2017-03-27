# -*- encoding : utf-8 -*-
require 'posix/spawn'
module TextExtractor
  class Png
    class << self
      def extract_text_cuneiform(file_pathes)
        text = ''
        file_pathes = Array(file_pathes)
        file_pathes.each do |file_path|
          output_path = "./tmp/#{ SecureRandom.hex(10) }.txt"
          result = ::POSIX::Spawn::Child.new(%{cuneiform -l eng -o #{ output_path } #{ file_path }}, timeout: 40, pgroup_kill: true)
          if result.err.blank? && ::File.exists?(output_path)
            ::File.open(output_path, 'r').each do |line|
              text << line
            end
            ::File.delete(output_path)
          end
        end

        text
      ensure
        file_pathes.each do |file_path|
          ::File.delete(file_path)
        end
      end

      def extract_text(file_pathes)
        file_pathes = Array(file_pathes)
        result = []

        result = file_pathes.first(5).map do |file_path|
          output_path = "./tmp/#{ SecureRandom.hex(10) }"
          result = ::POSIX::Spawn::Child.new(%{tesseract #{ file_path } #{ output_path } }, timeout: 40, pgroup_kill: true)
          output_path += '.txt'
          if ::File.exists?(output_path) || (result.err.blank? || result.err == %{"Tesseract Open Source OCR Engine v3.04.00 with Leptonica\nWarning in pixReadMemPng: work-around: writing to a temp file\n"})
            text = ::File.read(output_path)
            ::File.delete(output_path)
          end
          text
        end
=begin
        begin
          result = Parallel.map(file_pathes.first(5)) do |file_path|
            ActiveRecord::Base.connection.reconnect!
            output_path = "./tmp/#{ SecureRandom.hex(10) }"
            result = ::POSIX::Spawn::Child.new(%{tesseract #{ file_path } #{ output_path } }, timeout: 40, pgroup_kill: true)
            output_path += '.txt'
            if ::File.exists?(output_path) || (result.err.blank? || result.err == %{"Tesseract Open Source OCR Engine v3.04.00 with Leptonica\nWarning in pixReadMemPng: work-around: writing to a temp file\n"})
              text = ::File.read(output_path)
              ::File.delete(output_path)
            end
            text
          end
        rescue
        ensure
          ActiveRecord::Base.connection.reconnect!
        end
=end
        result.join('')
      ensure
        file_pathes.each do |file_path|
          ::File.delete(file_path)
        end
      end
    end
  end
end



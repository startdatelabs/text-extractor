namespace :text_extractor do
  desc 'Text Extractor install dependences'
  task :install_dependences do
    require File.join(TextExtractor.root, 'ext', 'extconf.rb')
  end
end

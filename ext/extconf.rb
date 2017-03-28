require 'mkmf'

DEPENDENCES_UBUNTU = %w{poppler-utils poppler-data libreoffice graphicsmagick tesseract-ocr tesseract-ocr-eng antiword unrtf unzip odt2txt ghostscript pdftk perl}
DEPENDENCES_MAC = %w{poppler graphicsmagick tesseract antiword unrtf unzip odt2txt ghostscript perl}

puts '****************'

if `uname -a`.include?('Ubuntu')
  dependences = DEPENDENCES_UBUNTU
  command = 'sudo apt-get'
  list = `apt list --installed`
else
  dependences = DEPENDENCES_MAC
  command = 'brew'
  list = `brew list`
end

dependences = dependences.reject { |d| list.include?(d) }

dependences.each do |tool|
  unless system("which #{ tool }")
    result = system("#{ command } install #{ tool }")
    puts result
  end
end

create_makefile('dependences')

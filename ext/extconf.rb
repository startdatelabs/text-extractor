require 'mkmf'

DEPENDENCES_UBUNTU = %w{poppler-utils poppler-data libreoffice graphicsmagick tesseract-ocr tesseract-ocr-eng antiword unrtf unzip odt2txt}
DEPENDENCES_MAC = %w{poppler graphicsmagick tesseract antiword unrtf unzip odt2txt}

puts '****************'

if `uname -a`.include?('Ubuntu')
  dependences = DEPENDENCES_UBUNTU
  command = 'sudo apt-get'
else
  dependences = DEPENDENCES_MAC
  command = 'brew'
  list = `brew list`
  dependences = dependences.reject { |d| list.include?(d) }
end

dependences.each do |tool|
  unless system("which #{ tool }")
    result = system("#{ command } install #{ tool }")
    puts result
  end
end

create_makefile('dependences')

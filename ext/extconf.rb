require 'mkmf'

DEPENDENCES_UBUNTU = %w{poppler-utils poppler-data libreoffice graphicsmagick tesseract-ocr tesseract-ocr-eng antiword unrtf unzip odt2txt ghostscript pdftk perl lynx-cur}
DEPENDENCES_MAC = %w{poppler graphicsmagick tesseract antiword unrtf unzip odt2txt ghostscript perl lynx}

puts '****************'
if `uname -a`.include?('Ubuntu')
  dependences = DEPENDENCES_UBUNTU
  command = "echo '#{ ENV['PASSWORD'] }' | sudo -S apt-get install -y"
  list = `dpkg -l`
else
  dependences = DEPENDENCES_MAC
  command = 'brew install'
  list = `brew list`
end

dependences = dependences.reject { |d| list.include?(d) }

dependences.each do |tool|
  unless system("which #{ tool }")
    result = system("#{ command } #{ tool }")
    puts result
  end
end

create_makefile('dependences')

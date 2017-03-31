require 'mkmf'

dependences_ubuntu = %w{poppler-utils poppler-data libreoffice graphicsmagick tesseract-ocr tesseract-ocr-eng antiword unrtf unzip odt2txt ghostscript pdftk perl lynx-cur}
dependences_mac = %w{poppler graphicsmagick tesseract antiword unrtf unzip odt2txt ghostscript perl lynx}

puts '****************'
if `uname -a`.include?('Ubuntu')
  dependences = dependences_ubuntu
  command = "echo '#{ ENV['PASSWORD'] }' | sudo -S apt-get install -y"
  list = `dpkg -l`
else
  dependences = dependences_mac
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

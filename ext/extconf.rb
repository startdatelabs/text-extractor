require 'mkmf'

def need_install(version, require_version)
  major, minor, tiny  = version.split('.').map(&:to_i)
  goal_major, goal_minor, goal_tiny  = require_version.split('.').map(&:to_i)

  if goal_major > major
    true
  elsif goal_minor > minor
    true
  elsif goal_tiny && goal_tiny > tiny
    true
  else
    false
  end
end

module InstallFromSourceCode
  def self.odt2txt
    `wget https://github.com/dstosberg/odt2txt/archive/master.zip`
    `unzip master.zip`
    `cd odt2txt-master && ./configure && make && make install`
  end
end

# if ENV['CI'].nil?
puts '****************'

if `which apt-get`.length > 0 # Ubuntu
  ubuntu_repositories = %w{ppa:libreoffice/ppa}

  ubuntu_repositories.each do |rep|
    system("echo '#{ ENV['PASSWORD'] }' | sudo -S add-apt-repository -y -r #{ rep }")
    system("echo '#{ ENV['PASSWORD'] }' | sudo -S add-apt-repository -y #{ rep }")
  end

  system("echo '#{ ENV['PASSWORD'] }' | sudo -S apt-get update")

  dependences = {
    'poppler-utils' => '0.41.0',
    'poppler-data' => '0.4.7-7',
    'libreoffice' => '6.2.5',
    'graphicsmagick' => '1.3.23',
    'tesseract-ocr' => '3.04.01',
    'tesseract-ocr-eng' => '3.04.00',
    'antiword' => '0.37',
    'unrtf' => '0.21.9',
    'unzip' => '6.0',
    'odt2txt' => '0.5',
    'ghostscript' => '9.26',
    'pdftk' => '2.02',
    'perl' => '5.22.1',
    'lynx' => '2.8.9'
  }

  command = "echo '#{ ENV['PASSWORD'] }' | sudo -S apt-get install -y"

  dependences.each do |tool, require_version|
    string_version = `dpkg -s #{ tool } | grep Version`
    regexp = require_version.count('.') == 1 ? /(\d+)\.(\d+)/ : /(\d+)\.(\d+)\.(\d+)/
    version = string_version.match(regexp).to_s

    if version.empty?
      system("#{ command } #{ tool }")
    elsif require_version
      system("#{ command } #{ tool }") if need_install(version, require_version)
    end
  end
elsif `which brew`.length > 0 # Mac OS X with installed brew
  `brew cleanup`
  `brew update`

  dependences = {
    'poppler' => '0.79.0',
    'graphicsmagick' => '1.3.33',
    'tesseract' => '4.1.0',
    'antiword' => '0.37',
    'unrtf' => '0.21.10',
    'unzip' => '6.0_2',
    'odt2txt' => '0.5',
    'ghostscript' => '9.27',
    'perl' => '5.30.0',
    'lynx' => '2.8.9rel.1'
  }
  dependences_cask = {
    'libreoffice' => '6.2.5'
  }
  versions = `brew list --versions`.split(/\n/)

  dependences.each do |tool, require_version|
    version = versions.find { |v| v.include?(tool) }
    if version
      v = version.split(' ')
      system("brew upgrade #{ tool }") if v && need_install(v[1], require_version)
    else
      system("brew install #{ tool }")
    end
  end

  `brew cask cleanup`
  versions = `brew cask list --versions`.split(/\n/)

  dependences_cask.each do |tool, require_version|
    version = versions.find { |v| v.include?(tool) }
    if version
      v = version.split(' ')
      system("brew cask upgrade #{ tool }") if v && need_install(v[1], require_version)
    else
      system("brew cask install #{ tool }")
    end
  end
else # docker alpine
  dependences = {
    'poppler-utils' => '0.41.0',
    #'poppler-data' => '0.4.6',
    'libreoffice' => '6.2.5',
    'graphicsmagick' => '1.3.23',
    'tesseract-ocr' => '3.04.01',
    #'tesseract-ocr-eng' => '3.02',
    'antiword' => '0.37',
    #'unrtf' => '0.21.5',
    'unzip' => '6.0',
    #'odt2txt' => '0.4',
    'ghostscript' => '9.26',
    'pdftk' => '2.02',
    'perl' => '5.22.1',
    'lynx' => '2.8.9'
  }

  #poppler-data
  #tesseract-ocr-eng
  #unrtf
  #odt2txt

  command = "apk add --no-cache"

  dependences.each do |tool, require_version|
    string_version = `apk version #{ tool }`
    regexp = require_version.count('.') == 1 ? /(\d+)\.(\d+)/ : /(\d+)\.(\d+)\.(\d+)/
    version = string_version.match(regexp).to_s

    if version.empty?
      system("#{ command } #{ tool }")
    elsif require_version
      system("#{ command } #{ tool }") if need_install(version, require_version)
    end
  end
end
# end

create_makefile('dependences') if ENV['SKIP_MAKEFILE'].nil?

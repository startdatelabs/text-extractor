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

# if ENV['CI'].nil?
puts '****************'

if `uname -a`.include?('Ubuntu')
  ubuntu_repositories = %w{ppa:libreoffice/ppa}

  ubuntu_repositories.each do |rep|
    system("echo '#{ ENV['PASSWORD'] }' | sudo -S add-apt-repository -y -r #{ rep }")
    system("echo '#{ ENV['PASSWORD'] }' | sudo -S add-apt-repository -y #{ rep }")
  end

  system("echo '#{ ENV['PASSWORD'] }' | sudo -S apt-get update")

  dependences = {
    'poppler-utils' => '0.24.5',
    'poppler-data' => '0.4.6',
    'libreoffice' => '6.0.4',
    'graphicsmagick' => '1.3.18',
    'tesseract-ocr' => '3.03.02',
    'tesseract-ocr-eng' => '3.02',
    'antiword' => '0.37',
    'unrtf' => '0.21.5',
    'unzip' => '6.0',
    'odt2txt' => '0.4',
    'ghostscript' => '9.14',
    'pdftk' => '2.01',
    'perl' => '5.18.2',
    'lynx-cur' => '2.8.9'
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
else
  `brew cleanup`

  dependences = {
    'poppler' => '0.53.0',
    'graphicsmagick' => '1.3.25',
    'tesseract' => '3.05.00',
    'antiword' => '0.37',
    'unrtf' => '0.21.9',
    'unzip' => '6.0_2',
    'odt2txt' => '0.5',
    'ghostscript' => '9.21',
    'perl' => '5.24.0',
    'lynx' => '2.8.8rel.2_1'
  }
  dependences_cask = {
    'libreoffice' => '6.0.4'
  }
  versions = `brew list --versions`.split(/\n/)
  command = 'brew install'

  dependences.each do |tool, require_version|
    version = versions.find { |v| v.include?(tool) }
    if version
      v = version.split(' ')
      system("#{ command } #{ tool }") if v && need_install(v[1], require_version)
    else
      system("#{ command } #{ tool }")
    end
  end

  `brew cask cleanup`
  versions = `brew cask list --versions`.split(/\n/)
  command = 'brew cask install'

  dependences_cask.each do |tool, require_version|
    version = versions.find { |v| v.include?(tool) }
    if version
      v = version.split(' ')
      system("#{ command } #{ tool }") if v && need_install(v[1], require_version)
    else
      system("#{ command } #{ tool }")
    end
  end
end
# end

create_makefile('dependences') if ENV['SKIP_MAKEFILE'].nil?

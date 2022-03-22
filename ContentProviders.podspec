# coding: utf-8
Pod::Spec.new do |s|

# MARK: - Description

  s.name                  = 'ContentProviders'
  s.summary               = 'A collection of useful content providers used for accessing and modifying iOS applications data.'
  s.version               = '1.6.1'

  s.platform              = :ios
  s.ios.deployment_target = '12.0'
  s.swift_version         = '5.5'

  s.cocoapods_version     = '~> 1.11.3'
  s.static_framework      = true

  s.homepage              = 'https://github.com/roxiemobile/content-providers.ios'
  s.authors               = { 'Roxie Mobile Ltd.' => 'sales@roxiemobile.com', 'Alexander Bragin' => 'bragin-av@roxiemobile.com' }
  s.license               = 'BSD-4-Clause'

# MARK: - Configuration

  s.source = {
    git: 'https://github.com/roxiemobile/content-providers.ios.git',
    tag: "v#{s.version}"
  }

# MARK: - Modules

  # A content provider used for accessing and modifying physical files.
  s.subspec 'FileSystem' do |sc|
    sc.dependency 'ContentProvidersFileSystem', s.version.to_s
  end

  # A content provider used for accessing and modifying data in SQLite database.
  s.subspec 'SQLite' do |sc|
    sc.dependency 'ContentProvidersSQLite', s.version.to_s
  end

  # A content provider used for accessing and modifying data in UserDefaults.
  s.subspec 'UserDefaults' do |sc|
    sc.dependency 'ContentProvidersUserDefaults', s.version.to_s
  end
end

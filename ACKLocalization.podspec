Pod::Spec.new do |s|
  s.name             = 'ACKLocalization'
  s.version          = '0.1.0'
  s.summary          = 'Localize app from Google Spreadsheet'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Localize your app from Google Spreadsheet using swift tool.
                       DESC

  s.homepage         = 'https://gitlab.ack.ee/iOS/localization'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ackee' => 'info@ackee.cz' }
  s.source           = { http: "https://github.com/AckeeCZ/ACKLocalization/download/#{s.version}/acklocalization-#{s.version}.zip" }
  s.preserve_paths   = '*'
end

Pod::Spec.new do |spec|
  spec.name         = "Improv-iOS"
  spec.version      = "0.0.2"
  spec.summary      = "Easily detect and connect Improv devices to WiFi networks in iOS"
  spec.description  = "This library abstracts the bluetooth scanning for Improv devices and allow you to connect them to WiFi networks"
  spec.author    = "Improv"

  spec.homepage     = "https://github.com/improv-wifi/sdk-iOS"
  spec.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
  spec.source       = { :git => "https://github.com/improv-wifi/sdk-iOS.git", :tag => "#{spec.version}" }
  spec.source_files  = "Improv-iOS/**/*.swift"

  spec.ios.deployment_target = "15.0"
  spec.osx.deployment_target = "12.0"
  spec.watchos.deployment_target = "8.0"


  spec.swift_versions = ['5.3']
end

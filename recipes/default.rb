#
# Author:: Joe Fitzgerald
# Cookbook Name:: chocolatey-installer
# Recipe:: default
#
# Copyright 2013, Joe Fitzgerald.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "chocolatey"

# install choco first to get commandline option
unless node['chocolatey-installer']['packages'].empty?
  chocolatey_package 'chocolatey' do
    action :install
  end

  if node['chocolatey-installer']['no_checksums'] == true
    powershell_script 'Skip checking of checksums for all chocolatey packages' do
      code <<-EOH
        $choco = [System.Environment]::GetEnvironmentVariable('ChocolateyInstall', 'MACHINE')
        $cmd = "& $choco\\bin\\choco.exe feature enable -n allowEmptyChecksums"        
        Invoke-Expression $cmd
      EOH
    end
  end
end

# install custom packages
node['chocolatey-installer']['packages'].each do |pack|
  opts = ''
  if node['chocolatey-installer']['no_checksums'] == true
    opts += '--allow-empty-checksums'
  end
  
  chocolatey_package pack do
    action :install
    options opts
  end
end

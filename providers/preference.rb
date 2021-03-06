#
# Cookbook Name:: apt
# Provider:: preference
#
# Copyright 2010-2011, Chef Software, Inc.
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

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

# Build preferences.d file contents
def build_pref(package_name, pin, pin_priority)
  "Package: #{package_name}\nPin: #{pin}\nPin-Priority: #{pin_priority}\n"
end

action :add do
  preference = build_pref(
    new_resource.glob || new_resource.package_name,
    new_resource.pin,
    new_resource.pin_priority
  )

  directory '/etc/apt/preferences.d' do
    owner 'root'
    group 'root'
    mode 00755
    recursive true
    action :create
  end

  if new_resource.filename.empty?
    filename = new_resource.name
  else
    filename = new_resource.filename
  end

  file "/etc/apt/preferences.d/#{filename}" do
    action :delete
    if ::File.exist?("/etc/apt/preferences.d/#{filename}")
      Chef::Log.warn "Replacing #{filename} with #{filename}.pref in /etc/apt/preferences.d/"
    end
  end

  file "/etc/apt/preferences.d/#{filename}.pref" do
    owner 'root'
    group 'root'
    mode 00644
    content preference
    action :create
  end
end

action :remove do
  if new_resource.filename.empty?
    filename = new_resource.name
  else
    filename = new_resource.filename
  end
  if ::File.exist?("/etc/apt/preferences.d/#{filename}.pref")
    Chef::Log.info "Un-pinning #{filename} from /etc/apt/preferences.d/"
    file "/etc/apt/preferences.d/#{filename}.pref" do
      action :delete
    end
  end
end

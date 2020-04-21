#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
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

name "vulcan-ctl"

license :project_license
source :path => "cookbooks/omnibus-vulcan"

dependency "omnibus-ctl"
dependency "chef-gem"
dependency "runit"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  bundle "install", env: env

  block do
    erb source: "vulcan-ctl.erb",
        dest: "#{install_dir}/bin/vulcan-ctl",
        mode: 0755,
        vars: {
          embedded_bin: "#{install_dir}/embedded/bin",
          embedded_service: "#{install_dir}/embedded/service",
        }
  end

  # additional omnibus-ctl commands
  sync "#{project_dir}/files/default/ctl-commands", "#{install_dir}/embedded/service/omnibus-ctl/"
end

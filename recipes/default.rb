#
# Cookbook Name:: etckeeper
# Recipe:: default
#
# Copyright 2012, Jeremiah Snapp
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

# use git for etckeeper's VCS
include_recipe "git"

package "etckeeper"

# run git garbage collection after each apt run
# this keeps etckeeper's git repo from getting too large over time
cookbook_file "/etc/etckeeper/post-install.d/99git-gc" do
  source "99git-gc"
  owner  "root"
  group  "root"
  mode   "0755"
  only_if { node[:etckeeper][:vcs] == "git" }
end

# tell etckeeper what VCS to use
template "/etc/etckeeper/etckeeper.conf" do
  source "etckeeper.conf.erb"
  owner  "root"
  group  "root"
  mode   "0644"
  variables(
    :etckeeper_vcs => node[:etckeeper][:vcs]
  )
  notifies :run, "execute[etckeeper_init]", :immediately
end

# initialize the etckeeper repo and make an initial commit
execute "etckeeper_init" do
  command "etckeeper init && etckeeper commit 'Initial commit.'"
  creates "/etc/.git"
  action  :nothing
end

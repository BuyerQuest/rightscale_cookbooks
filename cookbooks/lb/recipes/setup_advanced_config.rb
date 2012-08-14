# 
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

# Prepare user data to use in LWRP
# Example: node[:lb][:advanced_config][:backend_authorized_users] = "/serverid{admin:123, admin2:345}; /appserver{user1:678}"
if node[:lb][:advanced_config][:backend_authorized_users]
  base_string =node[:lb][:advanced_config][:backend_authorized_users]
  user_arr = base_string.gsub(/\s+/, "").split(";")
  cred_store = Hash.new

  user_arr.each do |record|
    backend_name = record[/(.+)\{/][$1]  # => /serverid
    users = record[/\{(.+)\}/][$1] # -> admin:123, admin2:345
    user_array = users.split "," # -> ["admin:123","admin2:345"]
    cred_store["#{backend_name}"]= user_array

    backend_short_name = backend_name.gsub(/[\/]/, '_')

    lb backend_short_name do
      backend_authorized_users cred_store["#{backend_name}"]
      action :advanced_configs
    end

  end
end


if node[:lb][:advanced_config][:backend_authorized_users]
  base_string = node[:lb][:advanced_config][:backend_authorized_users]
  entry_items = base_string.gsub(/\s+/, "").split(";")

  entry_items.each do |record|
    # example: "/serverid{admin:password, admin2:password2}
    record =~ (/^(.+)\{(.+)\}/)
    # users_array = [ "admin:password", "admin2:password2" ]
    users_array = $2.split(",")
    # backend_short_name = "_serverid"
    backend_short_name = $1.gsub(/[\/]/, '_')

    lb backend_short_name do
      backend_authorized_users users_array
      action :advanced_configs
    end

  end
end


rightscale_marker :end

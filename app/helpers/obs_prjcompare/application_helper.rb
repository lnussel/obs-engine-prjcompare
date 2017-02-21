# Copyright (C) 2017 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

module ObsPrjcompare
  module ApplicationHelper

    # Catch some url helpers used in the OBS layout and forward them to
    # the main application
    %w(root_path project_show_path search_path user_show_url user_show_path user_logout_path
       user_login_path user_register_user_path user_do_login_path news_feed_path project_toggle_watch_path 
       project_list_public_path monitor_path projects_path new_project_path).each do |m|
      define_method(m) do |*args|
        main_app.send(m, *args)
      end
    end

  end
end

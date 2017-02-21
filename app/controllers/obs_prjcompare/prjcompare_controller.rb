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

  class PrjcompareController < ApplicationController
    respond_to :html

    before_action :_setup

    def _setup
      @p = Project.find_by(name: params[:project])
      unless @p
        redirect_to main_app.root_path, flash: { error: "#{params[:project]} doesn't work" }
	return
      end
      # @project is used by breadcrumbs but doesn't work with the
      # delegate class as breadcrumbs check kind_of
      @project = Prjcompare.new(@p)
    end

    def show
      @diff_projects = nil
      a = @project.find_attribute('openSUSE', 'DiffTo')
      if a
	@diff_projects = a.values.map(&:value)
      elsif @project.name != 'openSUSE:Factory'
	@diff_projects = [ 'openSUSE:Factory' ]
      end
    end

    def compare
      @mode = params[:mode] || 'equal'
      p = Project.find_by(name: params[:project2])
      if p.nil?
        redirect_to prjcompare_show_path, flash: { error: "#{params[:project2]} not found" }
	return
      end
      project2 = Prjcompare.new(p)
      @pkglist = @project.compare_packages(project2, @mode)
    end

  end
end

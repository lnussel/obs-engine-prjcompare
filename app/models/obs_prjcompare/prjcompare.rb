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

require 'open-uri'
require 'delegate'

module ObsPrjcompare

  class Prjcompare < DelegateClass(::Project)

    attr_accessor :srcinfos
    attr_accessor :compare_modes

    def initialize(wrapped)
      @compare_modes = [ 'diff', 'equal', 'source', 'target' ]
      super
    end

    class SrcInfo
      attr_accessor :srcmd5, :verifymd5, :name

      def initialize(name, srcmd5, verifymd5 = nil)
        @name = name
        @srcmd5 = srcmd5
        @verifymd5 = verifymd5 || srcmd5
      end

    end

    class ComparisionResult
      attr_accessor :projects, :packages

      def initialize
        @projects = Array.new
        @packages = Hash.new
      end

      def add_column(name)
        if @packages.length == 0
          @projects.push(name)
        else
          # XXX: can't add columns if we already have packages
          raise UnknownObjectError
        end
      end

      def add_package(name, values)
        if values.length != @projects.length
          # XXX
          raise UnknownObjectError
        end
        @packages[name] = values
      end
    end

    def _fetch_srcinfos
      if @srcinfos.nil?
        @srcinfos = Hash.new
        x = Xmlhash.parse(Suse::Backend.get('/getprojpack?withsrcmd5=1&project=' + name).body)
        x.elements('project').each do |p|
          p.elements('package').each do |e|
            name = e['name']
            @srcinfos[name] = SrcInfo.new(name, e['srcmd5'], e['verifymd5'])
          end
        end
      end
    end

    def verifymd5(pkgname)
      _fetch_srcinfos
      if @srcinfos.has_key?(pkgname)
        return @srcinfos[pkgname].verifymd5
      end
    end

    def compare_packages(project2, mode = 'diff')
      result = ComparisionResult.new
      if mode == 'source'
        result.add_column(self.name)
        packages.each do |p|
          if ! project2.packages.find_by_name(p.name)
              result.add_package(p.name, [verifymd5(p.name)])
          end
        end
      elsif mode == 'target'
        result.add_column(project2.name)
        project2.packages.each do |p|
          if ! packages.find_by_name(p.name)
              result.add_package(p.name, [project2.verifymd5(p.name)])
          end
        end
      else
        result.add_column(self.name)
        result.add_column(project2.name)
        tmp = Hash.new
        packages.each do |p|
          tmp[p.name] = verifymd5(p.name)
        end
        project2.packages.each do |p|
          md5 = project2.verifymd5(p.name)
          if mode == 'equal'
            if tmp.has_key?(p.name) && tmp[p.name] == md5
              result.add_package(p.name, [ tmp[p.name], md5 ])
            end
          elsif mode == 'diff'
            if tmp.has_key?(p.name) && tmp[p.name] != md5
              result.add_package(p.name, [ tmp[p.name], md5 ])
            end
          end
        end
      end
      result
    end

  end

end

# vim:sw=2 et

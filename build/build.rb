# build.rb - Build script for the motiro project
#
# Copyright (c) 2006-2007 Thiago Arrais
#
# This program is free software.
# You can distribute/modify this program under the terms of
# the GNU LGPL, Lesser General Public License version 2.1.
#

def do_real_build
    `rails -s src`
end

def build(home)
    old_wd = Dir.getwd
    Dir.chdir home

    do_real_build

    Dir.chdir old_wd
end

motiro_home = File.dirname($0) + '/..'

build(motiro_home)





#!/bin/bash
# csvn - wrapper program to provide extra nifty features for client
#        side subversion usage.
#
# Copyright (C) 2011  Thomas Bracht Laumann Jespersen <laumann.thomas@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# To contact the author by e-mail: laumann.thomas@gmail.com
#
# To contact the author by paper mail:
#    Thomas Bracht Laumann Jespersen
#    Greisvej 40, 1. TH
#    DK-2300 Copenhagen S
#    Denmark
#

# Print usage information
usage() {
    echo "$CSVN - wrapper program to provide extra nifty features for client side"
    echo "          subversion usage."
    echo
    echo "Usage:  $CSVN [<csvn options> --] <svn command>"
    echo "        $CSVN [-v|--version]"
    echo "        $CSVN [-h|--help]"
    echo
    echo " Client side Subversion sucks - there is very little customisability, which"
    echo " completely ruins the experience for a lot of users. This bundle of scripts wraps"
    echo " around the svn command line tool to provide the extra functionality that YOU want."
    echo 
    echo "csvn options:"
    echo "   --svn=<path>    Use path as Subversion executable."
    exit 0
}
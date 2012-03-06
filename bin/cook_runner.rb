# === Synopsis:
#   RightScale Chef Cook (cook) - (c) 2010-11 RightScale Inc
#
#   This utility is meant to be used internally by RightLink, use
#   rs_run_right_script and rs_run_recipe instead.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'activate_bundler'))

require 'right_agent'
require 'eventmachine'
require 'chef'
require 'fileutils'
require 'right_scraper'

BASE_DIR = File.join(File.dirname(__FILE__), '..')

require File.normalize_path(File.join(BASE_DIR, 'lib', 'instance'))
require File.normalize_path(File.join(BASE_DIR, 'lib', 'instance', 'cook'))

# Launch it!
cook = RightScale::Cook.new
options = cook.parse_args
cook.run(options)

#
# Copyright (c) 2009-2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

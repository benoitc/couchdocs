#! /usr/bin/env ruby

require 'webrick'
include WEBrick

s = HTTPServer.new(:Port => 8080, :DocumentRoot => Dir::pwd + "/htdocs")
trap("INT"){s.shutdown}
s.start

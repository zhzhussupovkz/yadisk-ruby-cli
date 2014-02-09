#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'yadisk_cli'

disk = YadiskCli.new 'your login', 'your password'
disk.run

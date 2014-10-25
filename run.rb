#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'yadisk_cli'

# default location "ru"
disk = YadiskCli.new 'your login', 'your password', 'ru'
disk.run

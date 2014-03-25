=begin
/*

The MIT License (MIT)

Copyright (c) 2014 Zhussupov Zhassulan zhzhussupovkz@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/
=end
require "optparse"
require_relative 'yadisk_api'

class YadiskCli
  def initialize login, pass
    @yadisk = YadiskApi.new login, pass
    @cli = {}

    @global = OptionParser.new do |opts|
      opts.banner = "Command-line tool for working with Yandex.Disk\n"
      opts.banner += "Copyright (c) 2014 Zhussupov Zhassulan zhzhussupovkz@gmail.com\n"
      opts.banner += "Commonly used command are:\n
      upload : Upload file to the Yandex.Disk\n
      download : Download file from the Yandex.Disk\n
      create: Create directory in the Yandex.Disk\n
      del: Delete file or directory from the Yandex.Disk\n
      copy: Copy file or directory on the Yandex.Disk\n
      move: Move file or directory on the Yandex.Disk\n
      space: Get free and available space on the Yandex.Disk\n
      list: List of files on the Yandex.Disk\n
      share: Share file or directory from the Yandex.Disk\n
      private: Set private file or directory from the Yandex.Disk\n
      preview: Get image preview from the Yandex.Disk\n
      See 'run.rb COMMAND --help' for more information on a specific command.\n"
    end

    @commands = {

      #download files from server
      'download' =>  OptionParser.new do |opts|
        opts.banner = "Download file from Yandex.Disk\n"

        opts.on('-h', '--help', "help page") do
          puts opts
          exit
        end

        opts.on('-i', '--input FILENAME', "Filename from Yandex.Disk") do |o|
          cli[:file] = o
        end

        opts.on('-o', '--output FILENAME', "Output filename Yandex.Disk") do |o|
          cli[:output] = o
        end
      end,

      #upload files to the server
      'upload' =>  OptionParser.new do |opts|
        opts.banner = "Upload file to the Yandex.Disk\n"

        opts.on('-h', '--help', "help page") do
          puts opts
          exit
        end

        opts.on('-f', '--file FILENAME', "Local file name Yandex.Disk") do |o|
          cli[:file] = o
        end

        opts.on('-d', '--dir FILENAME', "Directory name from the Yandex.Disk") do |o|
          cli[:dir] = o
        end
      end,

      #create directory in the server
      'create' =>  OptionParser.new do |opts|
        opts.banner = "Create directory in the Yandex.Disk\n"

        opts.on('-h', '--help', "help page") do
          puts opts
          exit
        end

        opts.on('-d', '--dir DIRECTORY', "Directory name for create in Yandex.Disk") do |o|
          cli[:dir] = o
        end
      end,

      #delete directory from the server
      'del' =>  OptionParser.new do |opts|
        opts.banner = "Delete directory or file from the Yandex.Disk\n"

        opts.on('-h', '--help', "help page") do
          puts opts
          exit
        end

        opts.on('-d', '--dir DIRECTORY', "Directory name for delete in Yandex.Disk") do |o|
          cli[:dir] = o
        end
      end,

      #copy files and directories in the server
      'copy' =>  OptionParser.new do |opts|
        opts.banner = "Copy directory or file in the Yandex.Disk\n"

        opts.on('-h', '--help', "help page") do
          puts opts
          exit
        end

        opts.on('-f', '--from FILENAME', "File or directory name from Yandex.Disk") do |o|
          cli[:from] = o
        end

        opts.on('-t', '--to FILENAME', "Destination filename Yandex.Disk") do |o|
          cli[:to] = o
        end
      end,

      #move files and directories in the server
      'move' =>  OptionParser.new do |opts|
        opts.banner = "Move directory or file in the Yandex.Disk\n"

        opts.on('-h', '--help', "help page") do
          puts opts
          exit
        end

        opts.on('-f', '--from FILENAME', "File or directory name from Yandex.Disk") do |o|
          cli[:from] = o
        end

        opts.on('-t', '--to FILENAME', "Destination filename Yandex.Disk") do |o|
          cli[:to] = o
        end
      end,

      #list of files and directories
      'list' =>  OptionParser.new do |opts|
        opts.banner = "List of files and directories from the Yandex.Disk\n"

        opts.on('-h', '--help', "help page") do
          puts opts
          exit
        end

        opts.on('-d', '--dir FILENAME', "File or directory name from Yandex.Disk") do |o|
          cli[:dir] = o
        end

        opts.on('-a', '--amount INT', "Amount parameter for pagination list Yandex.Disk") do |o|
          cli[:amount] = o
        end

        opts.on('-o', '--offset INT', "Offset parameter for pagination list Yandex.Disk") do |o|
          cli[:offset] = o
        end
      end,

      #share folder or file from the server
      'share' =>  OptionParser.new do |opts|
        opts.banner = "Share directory of file from the Yandex.Disk\n"

        opts.on('-h', '--help', "help page") do
          puts opts
          exit
        end

        opts.on('-d', '--dir DIRECTORY', "Directory or file name for share in Yandex.Disk") do |o|
          cli[:dir] = o
        end
      end,

      #set private folder or file from the server
      'private' =>  OptionParser.new do |opts|
        opts.banner = "Set private directory of file from the Yandex.Disk\n"

        opts.on('-h', '--help', "help page") do
          puts opts
          exit
        end

        opts.on('-d', '--dir DIRECTORY', "Directory or file name for setting private in Yandex.Disk") do |o|
          cli[:dir] = o
        end
      end,

      #get image preview from the server
      'preview' =>  OptionParser.new do |opts|
        opts.banner = "Get image preview and download from the Yandex.Disk\n"

        opts.on('-h', '--help', "help page") do
          puts opts
          exit
        end

        opts.on('-f', '--file FILENAME', "Filename for preview from Yandex.Disk. For images only.") do |o|
          cli[:file] = o
        end

        opts.on('-s', '--size SIZE', "Image size from Yandex.Disk") do |o|
          cli[:size] = o
        end
      end
    }
    global.order!
  end

  attr_accessor :cli, :commands, :global
  attr_reader :yadisk, :main

  #rum cli tool
  def run
    cmd = ARGV.shift
    if cmd.nil?
      puts global
      exit
    end
    commands[cmd].order!
    case cmd
    when 'upload'
      yadisk.upload_file options = cli
    when 'download'
      yadisk.download_file cli
    when 'create'
      yadisk.mkdir options = cli
    when 'del'
      yadisk.rm cli
    when 'copy'
      yadisk.copy cli
    when 'move'
      yadisk.move cli
    when 'space'
      yadisk.get_space
    when 'list'
      dir = cli[:dir] || '/'
      cli.delete(:dir)
      yadisk.get_list dir, cli
    when 'share'
      yadisk.share cli
    when 'private'
      yadisk.set_private cli
    when 'preview'
      yadisk.image_preview options = cli
    end
  end

end
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

require 'net/http'
require 'net/https'
require 'openssl'
require 'base64'
require 'digest'
require 'cgi'
require 'rexml/document'

#YadiskApi - sipmlest class for working with yandex.disk
class YadiskApi

  def initialize login, pass, location
    @login, @pass, @location = login, pass, location
    uri = URI.parse "https://webdav.yandex.#{@location}"
    @http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  attr_reader :http

  #upload file to the server
  def upload_file options = {}
    dir = options[:dir] || '/'
    if options[:file].nil? || !options.key?(:file)
      puts "Please, set filename"
      exit
    else
      file = options[:file]
    end
    req = Net::HTTP::Put.new (dir + file)
    req.basic_auth @login, @pass
    etag = Digest::MD5.hexdigest File.read(file)
    sha = Digest::SHA256.hexdigest File.read(file)
    size = File.size(file)
    req['Host'] = "webdav.yandex.#{@location}"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Accept'] = "*/*"
    req['Etag'] = etag
    req['Sha256'] = sha
    req['Expect'] = "100-continue"
    req['Content-Type'] = "application/binary"
    req['Content-Length'] = size
    res = http.request(req, File.read(file))
    if res.code == "201"
      puts "File #{file} successfully uploaded to #{dir} path"
    else
      puts "File #{file} is not uploaded"
    end
  end

  #download file from server
  def download_file options = {}
    if options[:file].nil? || !options.key?(:file)
      puts "Please, set filename from server"
      exit
    else
      file = options[:file]
    end
    if options[:output].nil? || !options.key?(:output)
      puts "Please, set local file name"
      exit
    else
      output = options[:output]
    end
    req = Net::HTTP::Get.new file
    req.basic_auth @login, @pass
    req['Host'] = "webdav.yandex.#{@location}"
    req['Accept'] = "*/*"
    req['User-Agent'] = "yadisk-ruby-cli"
    res = http.request(req)
    if res.code == "200"
      data = res.body
      File.new("#{output}", 'wb').write(data)
      puts "File #{file} successfully downloaded to #{output}"
    else
      puts "File #{file} is not downloaded" 
    end
  end

  #create directory in the server
  def mkdir options = {}
    if options[:dir].nil? || !options.key?(:dir)
      puts "Please, set new file or directory name"
      exit
    else
      dir = options[:dir]
    end
    req = Net::HTTP::Mkcol.new dir
    req.basic_auth @login, @pass
    req['Host'] = "webdav.yandex.#{@location}"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Accept'] = "*/*"
    res = http.request(req)
    if res.code == "201"
      puts "Directory #{dir} successfully created in the server"
    else
      puts "Directory #{dir} creating is crashed"
    end
  end

  #copy directories and files
  def copy options = {}
    if options[:from].nil? || !options.key?(:from)
      puts "Please, set file or path name for copy"
      exit
    else
      from = options[:from]
    end
    if options[:to].nil? || !options.key?(:to)
      puts "Please, set destination file or path name"
      exit
    else
      to = options[:to]
    end
    req = Net::HTTP::Copy.new from
    req.basic_auth @login, @pass
    req['Host'] = "webdav.yandex.#{@location}"
    req['Accept'] = "*/*"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Destination'] = to
    res = http.request(req)
    if res.code == "201"
      puts "#{from} successfully copied to #{to}"
    else
      raise "#{from} is not copied"
    end
  end

  #move directories and files
  def move options = {}
    if options[:from].nil? || !options.key?(:from)
      puts "Please, set file or path name for move"
      exit
    else
      from = options[:from]
    end
    if options[:to].nil? || !options.key?(:to)
      puts "Please, set destination file or path name"
      exit
    else
      to = options[:to]
    end
    req = Net::HTTP::Move.new from
    req.basic_auth @login, @pass
    req['Host'] = "webdav.yandex.#{@location}"
    req['Accept'] = "*/*"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Destination'] = to
    res = http.request(req)
    if res.code == "201"
      puts "#{from} successfully moved to #{to}"
    else
      puts "#{from} is not moved"
    end
  end

  #remove directory or files from the server
  def rm options = {}
    if options[:dir].nil? || !options.key?(:dir)
      puts "Please, set file or directory name for delete"
      exit
    else
      dir = options[:dir]
    end
    req = Net::HTTP::Delete.new dir
    req.basic_auth @login, @pass
    req['Host'] = "webdav.yandex.#{@location}"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Accept'] = "*/*"
    res = http.request req
    if res.code == "200"
      puts "Directory #{dir} successfully deleted from the server"
    else
      puts "Directory #{dir} not deleted"
    end
  end

  #get used and all disk space
  def get_space
    quota = '<D:propfind xmlns:D="DAV:">
      <D:prop>
      <D:quota-available-bytes/>
      <D:quota-used-bytes/>
      </D:prop></D:propfind>'
    req = Net::HTTP::Propfind.new '/'
    req.basic_auth @login, @pass
    req['Host'] = "webdav.yandex.#{@location}"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Accept'] = "*/*"
    req['Depth'] = "0"
    req.body = quota
    res = http.request req
    if res.code == "207"
      data = res.body
      xml = REXML::Document.new data
      stats = xml.elements['d:multistatus/d:response/d:propstat/d:prop/d:quota-used-bytes']
      used = stats.to_s.gsub('<d:quota-used-bytes>', '').gsub('</d:quota-used-bytes>', '')
      stats = xml.elements['d:multistatus/d:response/d:propstat/d:prop/d:quota-available-bytes']
      available = stats.to_s.gsub('<d:quota-available-bytes>', '').gsub('</d:quota-available-bytes>', '')
      puts "Used disk space: #{used} bytes"
      puts "All disk space: #{available} bytes"
    else
      puts "Invalid returned data from server"
    end
  end

  #get list of files and directories
  def get_list dir = '/', options = { :amount => 3, :offset => 3 }
    options = URI.escape(options.collect{ |k,v| "#{k}=#{v}"}.join('&'))
    req = Net::HTTP::Propfind.new dir + '/?' + options
    req.basic_auth @login, @pass
    req['Host'] = "webdav.yandex.#{@location}"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Accept'] = "*/*"
    req['Depth'] = "1"
    res = http.request req
    if res.code == "207"
      data = res.body
      xml = REXML::Document.new data
      doc = xml.elements['d:multistatus']
      puts "List of files and directories in #{dir}:"
      doc.each do |e|
        href = URI.decode e[0].to_s.gsub('<d:href>', '').gsub('</d:href>', '')
        puts CGI::unescape href
        main = '<?xml version="1.0" encoding="utf-8"?><d:multistatus xmlns:d="DAV:">' + e[1].to_s + "</d:multistatus>"
        xml = REXML::Document.new main
        prop = xml.elements['d:multistatus/d:propstat/d:prop/d:getcontenttype']
        if prop.nil?
          ct = 'directory'
        else
          ct = prop.to_s.gsub('<d:getcontenttype>', '').gsub('</d:getcontenttype>', '')
        end
        puts "Content type: " + ct
        prop = xml.elements['d:multistatus/d:propstat/d:prop/d:creationdate']
        puts "Creation date: " + prop.to_s.gsub('<d:creationdate>', '').gsub('</d:creationdate>', '')
        prop = xml.elements['d:multistatus/d:propstat/d:prop/d:getlastmodified']
        puts "Last modified: " + prop.to_s.gsub('<d:getlastmodified>', '').gsub('</d:getlastmodified>', '')
        prop = xml.elements['d:multistatus/d:propstat/d:prop/d:getcontentlength']
        if prop.nil?
          length = '0'
        else
          length = prop.to_s.gsub('<d:getcontentlength>', '').gsub('</d:getcontentlength>', '')
        end
        puts "Content length: " + length + " bytes"
        puts ''
      end
    else
      puts "Invalid returned data from server"
    end
  end

  #share file or directory
  def share options = {}
    if options[:dir].nil? || !options.key?(:dir)
      puts "Please, set file or directory name for share"
      exit
    else
      dir = options[:dir]
    end
    req = Net::HTTP::Proppatch.new dir
    req.basic_auth @login, @pass
    send = '
    <propertyupdate xmlns="DAV:"><set><prop>
      <public_url xmlns="urn:yandex:disk:meta">true</public_url>
    </prop></set></propertyupdate>'
    req['Host'] = "webdav.yandex.#{@location}"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Content-Length'] = send.size
    req.body = send
    res = http.request req
    if res.code == "207"
      data = res.body
      xml = REXML::Document.new data
      doc = xml.elements['d:multistatus/d:response/d:propstat/d:prop/public_url']
      puts "Share link for #{dir}: " + doc[0].to_s
    else
      puts "Invalid returned data from server"
    end
  end

  #set private file or directory
  def set_private options = {}
    if options[:dir].nil? || !options.key?(:dir)
      puts "Please, set file or directory name for private"
      exit
    else
      dir = options[:dir]
    end
    req = Net::HTTP::Proppatch.new dir
    req.basic_auth @login, @pass
    send = '
    <propertyupdate xmlns="DAV:"><remove><prop>
      <public_url xmlns="urn:yandex:disk:meta"/>
    </prop></remove></propertyupdate>'
    req['Host'] = "webdav.yandex.#{@location}"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Content-Length'] = send.size
    req.body = send
    res = http.request req
    if res.code == "207"
      puts "#{dir} is successfully private"
    else
      puts "Invalid returned data from server"
    end
  end

  #get image preview from server - only for images
  def image_preview options = {}
    if options[:file].nil? || !options.key?(:file)
      puts "Please, set filename for preview"
      exit
    else
      file = options[:file]
    end
    size = options[:size] || 'XS'
    req = Net::HTTP::Get.new file + "/?preview&size=#{size}"
    req.basic_auth @login, @pass
    req['Host'] = "webdav.yandex.#{@location}"
    req['User-Agent'] = "yadisk-ruby-cli"
    res = http.request req
    if res.code == "200"
      data = res.body
      basename = File.basename file
      ext = File.extname(basename)
      output = basename.gsub(ext, "-preview-#{size}#{ext}")
      File.new("#{output}", 'wb').write(data)
      puts "#{file} preview is successfully downloaded"
    else
      puts "Invalid returned data from server"
    end
  end

end
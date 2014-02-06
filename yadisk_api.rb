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

#YadiskApi - sipmlest class for working with yandex.disk
class YadiskApi

  def initialize login, pass
    @login, @pass = login, pass
    @api_url = 'https://webdav.yandex.ru'
  end

  #upload file to the server
  def upload_file options = { :dir => '/', :file => nil }
    url = @api_url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    dir = options[:dir]
    file = options[:file]
    req = Net::HTTP::Put.new (dir + file)
    req.basic_auth(@login, @pass)
    etag = Digest::MD5.hexdigest File.read(file)
    sha = Digest::SHA256.hexdigest File.read(file)
    size = File.size(file)
    req['Host'] = "webdav.yandex.ru"
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
  def download_file options = { :file => nil, :output => nil }
    url = @api_url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    file = options[:file]
    output = options[:output]
    req = Net::HTTP::Get.new file
    req.basic_auth(@login, @pass)
    req['Host'] = "webdav.yandex.ru"
    req['Accept'] = "*/*"
    req['User-Agent'] = "yadisk-ruby-cli"
    res = http.request(req)
    if res.code == "200"
      data = res.body
      File.new("#{output}", 'wb').write(data)
      puts "File #{file} successfully downloaded to #{output}"
    else
      raise "File #{file} is not downloaded" 
    end
  end

  #create directory in the server
  def mkdir dir = nil
    url = @api_url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Mkcol.new dir
    req.basic_auth(@login, @pass)
    req['Host'] = "webdav.yandex.ru"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Accept'] = "*/*"
    res = http.request(req)
    if res.code == "201"
      puts "Directory #{dir} successfully created in the server"
    else
      raise "Directory #{dir} creating is crashed"
    end
  end

  #copy directories and files
  def copy options = { :from => nil, :to => nil }
    url = @api_url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    from = options[:from]
    to = options[:to]
    req = Net::HTTP::Copy.new from
    req.basic_auth(@login, @pass)
    req['Host'] = "webdav.yandex.ru"
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
  def move options = { :from => nil, :to => nil }
    url = @api_url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    from = options[:from]
    to = options[:to]
    req = Net::HTTP::Move.new from
    req.basic_auth(@login, @pass)
    req['Host'] = "webdav.yandex.ru"
    req['Accept'] = "*/*"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Destination'] = to
    res = http.request(req)
    if res.code == "201"
      puts "#{from} successfully moved to #{to}"
    else
      raise "#{from} is not moved"
    end
  end

  #remove directory or files from the server
  def rm dir = nil
    url = @api_url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Delete.new dir
    req.basic_auth(@login, @pass)
    req['Host'] = "webdav.yandex.ru"
    req['User-Agent'] = "yadisk-ruby-cli"
    req['Accept'] = "*/*"
    res = http.request(req)
    if res.code == "200"
      puts "Directory #{dir} successfully deleted from the server"
    else
      raise "Directory #{dir} not deleted"
    end
  end

end
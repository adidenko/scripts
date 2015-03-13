#!/usr/bin/ruby

begin
  require 'rubygems'
rescue LoadError
end
require 'ipaddr'
require 'ohai/system'
require 'pp'

unless Process.euid == 0
  puts "You must be root"
  exit 1
end

ENV['PATH'] = "/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

os = Ohai::System.new()
os.all_plugins

os[:network][:interfaces].each do |_, intinfo|
    next if intinfo[:state] == 'down' and ARGV[0] == 'skip'
    puts "==============="
    PP.pp(intinfo)
    intinfo[:addresses].each do |k, v|
      if v[:family] == 'inet' && !(IPAddr.new(k) rescue nil).nil?
        puts k
      end
    end
end
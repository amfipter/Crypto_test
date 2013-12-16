#!/usr/bin/env ruby

require 'socket'
require './util.rb'
require './simple_DES.rb'
require './server.rb'
require './client.rb'
require './signature.rb'
require './proof.rb'
include Util
include Crypt
include Simple_DES


# a = 'abracadabra'
# d = DES_encrypt(5, a)
# puts "enc"
# puts d
# d = DES_decrypt(5, d)
# puts "dec"
# puts d
# exit
g = Graph.new(10)
exit

s = Signature.new
s.mark(ARGV[0])
s.check((ARGV[0]))
exit



$ip = '127.0.0.1'
$port = 43045
$bits = 1024
$file_name = nil

if ARGV[0].eql?('-s')
  $server = true
else
  $server = false
end

# unless ARGV[1].nil?
#   $port = ARGV[1].to_i
# end

unless ARGV[1].nil?
	$file_name = ARGV[1]
end

# if ARGV[1].eql?('-t')
#   $test = true
# else
#   $test = false
# end

# if ($server == false and $test == false)
#   $file_name = ARGV[3]
# end

if ($server)
  $e, $d, $n = key_gen(1024)
  server = Server.new
else
  client = Client.new($file_name)
end






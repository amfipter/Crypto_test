#!/usr/bin/env ruby

require 'socket'
require './util.rb'
require './simple_DES.rb'
require './server.rb'
require './client.rb'
include Util
include Crypt
include Simple_DES

#puts exp(35, 10000000000, 100500)
#puts OpenSSL::BN::new(35.to_s).mod_exp(1000000,100500)
#exit

# a = 'abracadabra'
# d = DES_encrypt(5, a)
# puts "enc"
# puts d
# d = DES_decrypt(5, d)
# puts "dec"
# puts d
# exit


$ip = '127.0.0.1'
$port = 43045

if ARGV[0].eql?('-s')
  $server = true
else
  $server = false
end

# unless ARGV[1].nil?
#   $port = ARGV[1].to_i
# end

if ARGV[1].eql?('-t')
  $test = true
else
  $test = false
end

# if ($server == false and $test == false)
#   $file_name = ARGV[3]
# end

if ($server)
  $e, $d, $n = key_gen(1024)
  server = Server.new
else
  client = Client.new
end






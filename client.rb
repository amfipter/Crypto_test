class Client
  include Crypt
  include Util
  def initialize(file_name=nil)
    @port = $port
    @ip = $ip
    @file = file_name
    @size = 1024 * 1024 * 10
    #client
    shamir_client
  end

  def client
    puts "client started"
    server = TCPSocket.open(@ip, @port)
    e = server.gets.chomp.to_i
    n = server.gets.chomp.to_i
    s_key = gen_session_key
    enc_s_key = enc_num(s_key, e, n)
    puts e
    server.puts enc_s_key
    key = Digest::SHA256.hexdigest(s_key.to_s)
    puts key
  end

  def shamir_client
    raise Exception.new("need file") if @file.nil?
    #encoding: koi8-r
    server = TCPSocket.open(@ip, @port)
    byte_size = $bits / 8 - 1
    n = server.gets.chomp.to_i
    d1, d2, n = key_gen_shamir($bits, n)
    data = Array.new
    data.push @file
    file = File.open(@file, 'r')
    raw = file.read
    file.close
    data += raw.scan /.{#{byte_size}}/
    data.map {|i| i.bytes.inject {|a, b| (a<<8) + b}}
    server.puts data.size
    data.each {|i| shamir_send_msg(i, server, d1, d2, n)}
    server.close

  end

  def shamir_send_msg(msg, server, d1, d2, n)
    data1 = exp(msg.to_i, d1, n)
    server.puts data1
    data2 = server.gets.chomp
    data3 = exp(data2.to_i, d2, n)
    server.puts data3
  end

  def gen_session_key
    key = rand(2**63..2**64)
    key
  end

end
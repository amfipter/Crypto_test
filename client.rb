class Client
  include Crypt
  def initialize
    @port = $port
    @ip = $ip
    @size = 1024 * 1024 * 10
    client
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
    nil
  end

  def gen_session_key
    key = rand(2**63..2**64)
    key
  end

end
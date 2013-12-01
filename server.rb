class Server
  include Crypt
  include Simple_DES
  def initialize()
    @port = $port
    @ip = $ip
    @size = 1024 * 1024 * 10
    @server = TCPServer.open(@port)
    @client_e = nil
    @client_n = nil
    server
  end
  
  def server
    puts "server started"
    Signal.trap("INT") do
      puts "Terminating server.."
      exit
    end

    loop do
      Thread.start(@server.accept) do |client|
        puts "catch client " + client.to_s
        client.puts $e
        client.puts $n
        k_enc = client.gets.chomp.to_i
        #puts k_enc
        s_key = dec_num(k_enc)
        key = Digest::SHA256.hexdigest(s_key.to_s)
        puts key
        client.close
      end      
    end
  end

  def shamir_server
    nil
  end
end
class Server
  include Crypt
  include Simple_DES
  include Util
  def initialize()
    @port = $port
    @ip = $ip
    @size = 1024 * 1024 * 10
    @server = TCPServer.open(@port)
    @client_e = nil
    @client_n = nil
    #server
    shamir_server
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
    #encoding: koi8-r
    d1, d2, n = key_gen_shamir($bits)
    puts "server started"
    Signal.trap("INT") do
      puts "Terminating server.."
      exit
    end
    loop do
      data = Array.new
      client = @server.accept
      puts "client connect"
      client.puts n
      puts 'send n: ' + n.to_s

      num = client.gets.chomp.to_i
      puts "data size: " + num.to_s

      num.times {data.push shamir_get_msg(client, d1, d2, n)}
      puts "get data: " + data.size.to_s
      puts data
      data_t = Array.new
      data.each do |j|
        puts "================================"
        t = (j.to_s(16).split(/[, \.?!]+/).map {|i| i.to_i(16)}).pack('C*')
        puts j
        puts t
        puts "==========================================="
        data_t.push t 
      end
      data = data_t
      #data.map {|j| (j.to_s(16).scan(/../).map {|i| i.to_i(16)}).pack('c*')}
      #puts data
      exit
      f_name = data.shift
      puts f_name
      file = File.open(f_name.to_s + '.copy', 'w')
      data.each {|chunk| file.print chunk}
      file.close
    end

  end

  def shamir_get_msg(client, d1, d2, n)
    data1 = client.gets.chomp
    data2 = exp(data1.to_i, d1, n)
    client.puts data2
    data3 = client.gets.chomp
    data4 = exp(data3.to_i, d2, n)
    data4
  end
end
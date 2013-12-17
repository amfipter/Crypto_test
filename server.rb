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
    #rsa_server
    @proof_count = 100
    proof_server
  end
  
  def DES_server
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

  def proof_server
    puts "server started"
    graph = Graph.new()
    Signal.trap("INT") do
      puts "Terminating server.."
      exit
    end
    loop do
      data = nil 
      client = @server.accept 
      rsa_e = client.gets.chomp.to_i
      rsa_n = client.gets.chomp.to_i
      graph.rsa_e = rsa_e
      graph.rsa_n = rsa_n
      puts "Connected"
      @proof_count.times do
        client.puts "OK"
        data = client.gets.chomp
        graph.set_encrypted_graph(data)
        request = rand(1..2) #1-cycle; 2-isomorphic
        client.puts request.to_s
        if(request == 1)
          puts 'CYCLE TEST!!'
          encoded_path = client.gets.chomp
          unless(graph.check_encoded_path(encoded_path))
            puts "FAIL"
            puts "1-cycle"
            exit
          end
        elsif(request == 2)
          puts 'ISOMORPHIC TEST!!'
          translate_array = client.gets.chomp
          encoded_graph = client.gets.chomp
          graph.set_translate_array(translate_array)
          graph.set_encoded_graph(encoded_graph)
          unless(graph.check_isomorphic_graph())
            puts 'FAIL'
            puts '2-isomorphic'
            exit
          end
        end
        puts 'ITERATION'
      end
      client.puts "exit"
      puts "PROOF COMPLETE"


      
    end
  end

  def rsa_server
    #encoding: koi8-r
    e, d, n = key_gen($bits)
    puts "server started"
    Signal.trap("INT") do
      puts "Terminating server.."
      exit
    end
    loop do
      data = Array.new 
      client = @server.accept 
      puts "Connected"
      client.puts e
      client.puts n
      #puts "Keys"
      size = client.gets.chomp.to_i
      size.times do
        chunk = client.gets.chomp.to_i
        data.push exp(chunk, d, n)
      end
      data.map! {|i| (i.to_s(16).scan(/../).map {|j| j.to_i(16)}).pack('C*')}
      data.map! {|i| i.sub(/^./, '')}
      f_name = data.shift
      out = data.join
      File.open(f_name + '.copy', 'w') {|file| file.print(out) and file.close}
      puts "data " + Digest::SHA512.hexdigest(out)
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
        #t = (j.to_s(16).split(/[, \.?!]+/).map {|i| i.to_i(16)}).pack('C*')
        j1 = j.to_s(16)
        #j = '0' + j if j.size % 2 == 1
        t = (j1.scan(/../).map {|i| i.to_i(16)}).pack('C*')
        t.sub! /^./, ''
        puts j
        puts t
        puts "==========================================="
        data_t.push t 
      end
      data = data_t
      out = data.join
      puts out
      puts Digest::SHA512.hexdigest(out)
      #data.map {|j| (j.to_s(16).scan(/../).map {|i| i.to_i(16)}).pack('c*')}
      #puts data
      #exit
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

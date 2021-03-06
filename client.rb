class Client
  include Crypt
  include Util
  def initialize(file_name=nil)
    @port = $port
    @ip = $ip
    @file = file_name
    @size = 1024 * 1024 * 10
    #client
    #rsa_client
    proof_client
  end

  def DES_client
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

  def proof_client
    graph = Graph.new(10)
    graph.create
    rsa_e = graph.rsa_e
    rsa_n = graph.rsa_n
    puts rsa_e
    puts rsa_n
    data = graph.get_encrypted_graph
    server = TCPSocket.open(@ip, @port)
    server.puts rsa_e.to_s
    server.puts rsa_n.to_s
    puts "connect"
    loop do
      #cycle
      break if server.gets.chomp.eql?('exit')
      server.puts data
      request = server.gets.chomp.to_i
      if(request == 1)
        server.puts graph.get_encoded_path()
      elsif(request == 2)
        server.puts graph.get_translate_array()
        server.puts graph.get_encoded_graph()
      end
      graph.renew
      data = graph.get_encrypted_graph

    end

  end


  def rsa_client
    raise Exception.new("need file") if @file.nil?
    #encoding: koi8-r
    server = TCPSocket.open(@ip, @port)
    puts "connect"
    e = server.gets.chomp.to_i
    n = server.gets.chomp.to_i
    byte_size = $bits / 8 - 1
    data = Array.new
    File.open(@file, 'r') do |file| 
      while(chunk = file.read(byte_size)) do 
        data.push chunk
      end 
      file.close
    end
    out = data.join
    data.unshift @file
    data.map! {|i| "1" + i}
    data.map! {|i| i.bytes.inject {|a, b| (a<<8) + b}}
    server.puts data.size
    data.each {|el| server.puts exp(el, e, n)}
    server.close
    puts "data " + Digest::SHA512.hexdigest(out)
  end

  def shamir_client
    raise Exception.new("need file") if @file.nil?
    #encoding: koi8-r

    server = TCPSocket.open(@ip, @port)
    puts "connect"
    byte_size = $bits / 8 - 1
    n = server.gets.chomp.to_i
    #puts "get n: " + n.to_s

    d1, d2, n = key_gen_shamir($bits, n)
    data = Array.new
    data.push @file
    raw_arr = Array.new
    file = File.open(@file, 'r')
    chunk = file.read(byte_size)
    while (chunk)
      raw_arr.push chunk
      chunk = file.read(byte_size)
    end 
    #puts raw_arr
    #puts raw_arr.join
    file.close
    #exit
    data += raw_arr
    data.map! {|i| '1' + i}
    puts data
    #data.map {|i| i.bytes.inject {|a, b| (a<<8) + b}}
    data_t = Array.new
    data.each do |i|
      puts "==================================="
      t = i.bytes.inject {|a, b| (a<<8) + b}
      puts t
      puts i
      puts "============================================="
      data_t.push t
    end
    data = data_t
    raw_arr.unshift @file
    out = raw_arr.join
    puts Digest::SHA512.hexdigest(out)
    
    puts data
    puts "data: " + data.size.to_s
    server.puts data.size

    data.each {|i| shamir_send_msg(i, server, d1, d2, n)}
    puts "data send"
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

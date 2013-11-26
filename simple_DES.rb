require 'digest/sha2'
$fest_count = 16
module Simple_DES
  def DES_encrypt(k, data)
    data = str_parse(data) if data.class == String
    #puts "msg: " + data.to_s
  	need_dummy = false
    storage = Array.new
    enc_data = Array.new
    keys = keys_gen(k, $fest_count)
    iv_r = Random.new(k)
    iv = [iv_r.rand(256), iv_r.rand(256), iv_r.rand(256), iv_r.rand(256), iv_r.rand(256), iv_r.rand(256), iv_r.rand(256), iv_r.rand(256)]
    while(true)
      t = data.shift 8
      storage.push t
      need_dummy = true if t.size == 0
      break unless t.size == 8
    end
    if(need_dummy)
      storage.pop
      t = [8,8,8,8,8,8,8,8]
      storage.push t
    else
      t = storage.pop
      i = 8 - t.size
      i.times {t.push i}
      
      storage.push t
    end
    #puts ((keys[0])[0..3]).pack('CCCC').unpack('V')[0].to_s(2).size
    #puts "======"
    t = iv
    storage.each do |block|
      block = block_xor(block, t)
      #puts block.to_s
      $fest_count.times do |i|
        block = prime_fest(((keys[i])[0..3]).pack('CCCC').unpack('V')[0], block)
      end
      enc_data.push block
      t = block.clone
      # puts block.to_s
      # $fest_count.times do |i|
      #   block = back_fest(((keys[$fest_count - i - 1])[0..3]).pack('CCCC').unpack('V')[0], block)
      # end
      # puts block.to_s
    end
    #puts iv.to_s
    enc_data.unshift iv
    storage = enc_data
    #puts "======"

    storage.flatten!
    mac = MAC_gen(storage.clone)

    out = array_to_str(storage)
    out += mac

    #puts Digest::SHA512.hexdigest('test').size
    #puts storage.to_s
    #puts key_gen(1234, 5).to_s

    out
  end


  
  def DES_decrypt(k, data)
    need_dummy = false
    storage = Array.new
    enc_data = Array.new
    keys = keys_gen(k, $fest_count)
    enc_data = MAC_check(data)
    raise Exception.new('MAC check fail') if enc_data.nil?

    #puts enc_data.to_s
    storage = Array.new
    while (true)
      t = enc_data.shift 8
      storage.push t
      break if enc_data.size == 0
    end
    iv = storage.shift
    #puts iv.to_s
    t = iv
    data = Array.new
    #puts storage.to_s
    storage.each do |block|
      t1 = block
      $fest_count.times do |i|
         block = back_fest(((keys[$fest_count - i - 1])[0..3]).pack('CCCC').unpack('V')[0], block)
      end
      block = block_xor(block, t)
      data.push block
      t = t1
    end
    #puts data.to_s
    t = data.pop
    unless (t == [8,8,8,8,8,8,8,8])
      last_block = t
      trash_count = last_block[7]
      block_data = last_block[0..7-trash_count]
      data.push block_data
    end
    #puts data.to_s
    out = array_to_str(data.flatten)
    out

  end

  def prime_fest(k, block)
  	raise Exception.new("wrong block size") unless block.size == 8
  	raise Exception.new("wrong key size") if k.to_s(2).size > 32

  	l = (block[0..3]).pack('CCCC').unpack('V').pop.to_i
  	r = (block[4..7]).pack('CCCC').unpack('V').pop.to_i
  	f = f(k, r)
  	l1 = r
  	r1 = l ^ f
  	block = [l1].pack('V').unpack('CCCC')
  	block += [r1].pack('V').unpack('CCCC')
  	block
  end

  def back_fest(k, block)
  	raise Exception.new("wrong block size") unless block.size == 8
  	raise Exception.new("wrong key size") if k.to_s(2).size > 32

  	l = (block[0..3]).pack('CCCC').unpack('V').pop.to_i
  	r = (block[4..7]).pack('CCCC').unpack('V').pop.to_i
  	f = f(k, l)
  	l1 = r ^ f
  	r1 = l 
  	block = [l1].pack('V').unpack('CCCC')
  	block += [r1].pack('V').unpack('CCCC')
  	block
  end

  def keys_gen(k, num)
    keys = Array.new
    a = Random.new(k)
    num.times do
      t = a.bytes(32)
      t = Digest::SHA256.hexdigest(t).scan(/../).map {|x| x.to_i(16)}
      t1 = t[0..15]
      t2 = t[16..31]
      16.times { |i| t[i] = t1[i] ^ t2[i] }
      t1 = t[0..7]
      t2 = t[8..15]
      8.times { |i| t[i] = t1[i] ^ t2[i] }
      t = t[0..7]
      keys.push t.clone
    end
    keys
  end

  def f(k, b)
  	out = k^b
  	out
  end

  def MAC_check(data)
    data.reverse!
    data = data.split ''
    mac = data[0..127]
    enc_data = data[128..data.size-1]
    mac.reverse!
    enc_data.reverse!

    mac = mac.join
    enc = enc_data.join
    enc_data.map! {|i| i.ord}
    tag = Digest::SHA512.hexdigest(enc)
    return nil unless MAC_compare(mac, tag)
    enc_data
  end

  def MAC_compare(tag1, tag2)
    puts tag1
    puts tag2
    tag1 = tag1.split ''
    tag2 = tag2.split ''
    out = 0
    tag1.size.times do | i|
      out += tag1[i].ord ^ tag2[i].ord
    end
    return true if out == 0
    false    
  end

  def MAC_gen(data)
    t = ''
    data.each {|el| t += el.chr }
    out = Digest::SHA512.hexdigest(t)
    out
  end
  

  def block_xor(e1, e2)
    out = Array.new
    e1.size.times do |i|
      out.push e1[i] ^ e2[i]
    end
    out
  end

  def str_parse(str)
    data = str.split ''
    data.map! {|x| x.ord }
    data
  end

  def array_to_str(arr)
    t = ''
    arr.each {|x| t+= x.chr}
    t
  end
end
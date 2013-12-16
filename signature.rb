class Signature
  include Util
  def initialize()
    @n = nil
    @q = nil
    gen_keys_new()
  end

  def gen_keys_new()
    puts "gen keys"
    bits = 1024
    bits_1 = 256
    q = gen(bits_1)
    b = gen(bits - bits_1 - 1)
    b+=1
    puts miller_rabin_test(q,100)
    puts miller_rabin_test(b,100)
    n = 0
    i = 0
    while(true) do
      n = q * b + 1
      break if miller_rabin_test(n, 100)
      b += 2
      i += 1
      puts i if i%50000 == 0
    end
    puts "find " + i.to_s
    puts n.to_s + ' ' + miller_rabin_test(n, 100).to_s
    puts q.to_s + ' ' + miller_rabin_test(q, 100).to_s
    puts (n-1) / q
    puts (n-1) / (q + 1)
    puts n.size
    puts q.size
    puts n - b*q

    while(true)
      a = gen(32)
      a = exp(a, b, n)
      #puts '='
      #puts a
      #puts q
      #puts n
      w = exp(a, q, n)
      #puts 'end'
      #puts w
      break if w == 1
    end
    puts '______________'
    x = gen(128) #secret
    puts a
    puts x
    y = exp(a, x, n) #public
    puts '______________'


    @n = n
    @q = q
    @b = b
    @a = a
    @x = x
    @y = y
  end

  def mark(name)
    puts '==========='
    file = File.open(name, 'r') 
    data = file.read
    file.close
    hash = Digest::SHA512.hexdigest(data).to_i(16)
    puts hash
    n = 0
    #hash.bytes.inject {|a, b| (a<<8) + b}
    #puts hash
    while(true) do
      k = gen(128)
      r = exp(@a,k, @n) % @q
      s = (k*hash + @x*r) % @q
      break if r!=0 and s !=0
    end
    puts r
    puts s

    @r = r
    @s = s

  end

  def check(name)
    data = nil
    File.open(name, 'r') {|file| data = file.read and file.close}
    hash = Digest::SHA512.hexdigest(data).to_i(16)
    puts hash
    #hash.bytes.inject {|a, b| (a<<8) + b}
    #puts hash
    raise Exception.new("fail to check sign") if (@r <= 0 or @r >= @q or @s <= 0 or @s >= @q)
    h1 = inverse(hash, @n)
    u1 = @s*h1 % @q
    u2 = -@r*h1 % @q
    v = (exp(@a, u1, @n) * exp(@y, u2, @n) % @n) % @q
    puts "-------------"
    puts v
    puts @r
    raise Exception.new("fail to check sign") if v != @r
  end


  def gen_keys()
    bits = 128
    bits_1 = 32
    #n = gen(bits)
    i=0
    work = true
    q = 0
    4.times do |k|
      Thread.new do    
        n = gen(bits)
        while(work)
          i += 1
          q = gen(bits_1)
          if (n-1)%q == 0
            puts n
            puts q
            work = false
            break
          end
          if i%5000 == 0
            puts k
            puts i
            puts n
            #puts q
            n = gen(bits)
          end
        end
      end
    end
    Thread.list.each {|t| t.join}
    puts "find"
    puts n
    puts q
  end
end

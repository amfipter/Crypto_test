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
      #puts b%2
      #puts q%2
      #puts n%2
      #exit
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

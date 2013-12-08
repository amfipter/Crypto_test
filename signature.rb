class Signature
  include Util
  def initialize()
    @n = nil
    @q = nil
    gen_keys()
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

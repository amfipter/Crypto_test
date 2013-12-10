require 'openssl'

module Util
  def miller_rabin_test(n,g)
    return false if n < 2
    return true if n == 2
    return false if n%2 == 0
    d = n - 1
    s = 0
    while d % 2 == 0
      d /= 2
      s += 1
    end
    g.times do
      a = 2 + rand(n-4)
      #x = OpenSSL::BN::new(a.to_s).mod_exp(d,n) #x = (a**d) % n
      x = exp(a,d,n)
      next if x == 1 or x == n-1
      for r in (1 .. s-1)
        x = exp(x,2,n)  #x = (x**2) % n
        return false if x == 1
        break if x == n-1
      end
      return false if x != n-1
    end
    true  # probably
  end
  
  def simple_prime_test(m)
    n = Math.sqrt(m) + 1
    2.upto(n) do |i|
      return false if m%i == 0
    end
    return true
  end
  
  
  def key_gen(bits)
    while(true) do
    p = gen(bits)
    q = gen(bits)
    n = p*q
    e_n = (p-1) * (q-1)
    public_exp = gen_small(32)
    private_exp = inverse(public_exp, e_n)
    break if exp_test(public_exp, private_exp, e_n)
    end
    return public_exp, private_exp, n
  end

  def key_gen_shamir(bits, n=nil)
    n = gen(bits) if n.nil?
    e_n = n-1
    while(true) do
      d1 = gen(bits/2)
      d2 = inverse(d1, e_n)
      break if exp_test(d1, d2, e_n)
    end
    return d1, d2, n
  end
  
  def exp_test(public_exp, private_exp, e_n)
    return false if public_exp<0 or private_exp<0
    return true if private_exp*public_exp % e_n == 1
    false
  end
  
  def gen(bits)
    t = 2**(bits-1) + rand(2**bits - 1 - 2**(bits-1))
    until(miller_rabin_test(t, 100)) do
      t = 2**(bits-1) + rand(2**bits - 1 - 2**(bits-1))
    end
    t
  end
  
  def gen_small(bits)
    t = 2**(bits-1) + rand(2**bits - 1 - 2**(bits-1))
    until(simple_prime_test(t)) do
      t = 2**(bits-1) + rand(2**bits - 1 - 2**(bits-1))
    end
    t
  end
  
  def extend_euclid(a, b)
    q = nil
    r = nil
    x = 0
    y = 0
    d = 0
    x1 = 0
    x2 = 1
    y1 = 1
    y2 = 0
    if(b == 0)
      return x
    end
    while(b > 0)
      q = (a / b).to_i
      r = a - q*b
      x = x2 - q*x1
      y = y2 - q*y1
      a = b
      b = r
      x2 = x1
      x1 = x
      y2 = y1
      y1 = y
    end
    d = a
    x = x2
    y = y2
    return x, d
  end
  
  def inverse(a, n)
    x, d = extend_euclid(a, n)
    return x if d == 1
    nil
  end
end

module Crypt
  def dec_num(num)
    #out = OpenSSL::BN::new(num.to_s).mod_exp($d,$n) #exp(num, $d, $n) #(byte**$d) % $n
    out = exp(num, $d, $n)
    out
  end
  
  def enc_num(num, e, n)
    #out = OpenSSL::BN::new(num.to_s).mod_exp(e,n) #exp(num, e, n)  #(byte**e) % n
    out = exp(num, e, n)
    out
  end
  
  def bit_repr(num)
    num.to_i.to_s(2).split('').reverse
  end
  
  def exp(g, deg, m)
    # out = OpenSSL::BN::new(g.to_s).mod_exp(deg,m)
    # return out
    a = bit_repr(deg)
    z = 1
    y = g
    a.size.times do |t|
      z = z * y % m if a[t].eql? '1'
      y = y**2 % m
    end
    z
  end

  

end
  
class Graph
	include Crypt
  	include Util
	attr_accessor :G
	def initialize(num = 0)
		@E = Hash.new
		@V = Array.new
		@V_H = Array.new
		#@G = Array.new(num, Array.new(num, 0))
		@G = Hash.new
		
		#@G.each {|i| i = Array.new(num) }
		#mark_path(1,3)
		#@H = @G.clone
		@H = nil
		@H_ = nil
		@F = nil
		@n = num
		@translate_array = nil
		@rsa_e = nil
		@rsa_d = nil
		@rsa_n = nil
		@bits = 512
		#puts @translate_array.to_s
		create()
	end

	def crypt_matrix()
		if(@rsa_n.nil? or @rsa_d.nil? or @rsa_e.nil?)
			@rsa_e, @rsa_d, @rsa_n = key_gen(@bits)
		end
		@F = @H_.clone
		@F.keys.each do |i|
			@F[i].keys.each {|j| @F[i][j] = exp(@F[i][j], @rsa_e, @rsa_n)}
		end
	end

	def pack(m)
		v = m.keys
		v.unshift m.keys.size
		m.keys.each do |i|
			m[i].keys.each {|j| v.push m[i][j]}
		end
		puts v.to_s
		v.to_s
	end

	def unpack(str)
		str.sub!(/^./, '')
		str.sub!(/.$/, '')
		str.gsub!(',', '')
		data = str.split ' '
		data.map! {|i| i.to_i}
		n = data.shift
		@n = n if @n == 0
		v = Array.new 
		n.times do
			v.push data.shift
		end

		graph = Hash.new
		1.upto(n) do |i|
			graph[v[i-1]] = Hash.new
			1.upto(n) {|j| graph[v[i-1]][v[j-1]] = data.shift}
		end
		graph
	end


	def code_matrix()
		@H_ = clone(@H)
		@H_.keys.each do |i|
			@H_[i].keys.each {|j| @H_[i][j] += (rand(1..15) * 10)}
		end
		puts 'coding'
		m_print(@H_)
		#m_print(@H)
	end

	def clone(m)
		out = Hash.new
		m.keys.each do |i|
			out[i] = Hash.new
			m[i].keys.each {|j| out[i][j] = m[i][j]}
		end
		out
	end

	def decode_matrix()
		@H = clone(@H_)
		@H.keys.each do |i|
			@H[i].keys.each {|j| @H[i][j] = @H[i][j] % 10}
		end
		m_print(@H)
	end

	def cmp_matrix(m1, m2)
		# puts '========='
		# m_print(m1)
		# m_print(m2)
		out = 0
		1.upto(@n) do |i|
			1.upto(@n) {|j| out += m1[i][j] ^ m2[i][j]}
		end
		return true if out == 0
		false
	end

	def create()
		1.upto(@n) do |i|
			@G[i] = Hash.new
			1.upto(@n) {|j| @G[i][j] = 0}
		end
		generate_path()
		#gen_random_path()
		gen_isomorphic_graph()
		code_matrix()
		decode_matrix()
		puts gam_chech(@H, @V_H)
		puts cmp_matrix(unpack(pack(@H)), @H)
	end

	def gen_isomorphic_graph()
		@translate_array = (1..@n).entries.shuffle
		translate_hash = Hash.new
		1.upto(@n) do |i|
			translate_hash[i] = @translate_array[i-1]
		end
		@H = Hash.new
		1.upto(@n) do |i|
			h = Hash.new
			h_orig = @G[i]
			1.upto(@n) do |j|
				h[translate_hash[j]] = h_orig[j]
			end
			@H[translate_hash[i]] = h 
		end
		@V.each {|i| @V_H.push translate_hash[i]}

		m_print(@H)
		puts gam_chech(@H, @V_H)
		#puts translate_hash.to_s
	end

	def generate_path()
		@V = (1..@n).entries.shuffle
		puts @V.to_s
		(@V.size - 1).times do |i|
			e1 = @V[i]
			e2 = @V[i+1]
			mark_path(e1, e2)
		end
		m_print(@G)
		puts gam_chech(@G, @V)
	end

	def gen_random_path()
		n = 1
		@n.downto(@n - 2) {|i| n += i}
		n.times do |i|
			e1 = rand(1..@n)
			e2 = rand(1..@n)
			mark_path(e1, e2)
		end
		m_print(@G)
		puts gam_chech(@G, @V)
		puts n
	end

	def mark_path(e1, e2)
		# puts @G
		# puts @G.class
		# puts @G[e1].class
		# puts @G[e1][e2].class
		@G[e1][e2] = 1
		@G[e2][e1] = 1
	end

	def m_print(m)
		#puts m
		m.each_key do |i|
			print i.to_s + '   '
			puts m[i].to_s
		end
		puts ''
	end

	def gam_chech(m, ar)
		v = m.keys.sort
		return false if ar.sort != v
		(ar.size - 1).times do |i| 
			e = m[ar[i]][ar[i+1]]
			return false if e == 0
		end
		true
	end


end
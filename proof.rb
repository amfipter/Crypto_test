class Graph
	include Crypt
  	include Util
	attr_accessor :G, :rsa_e, :rsa_n, :translate_array
	def initialize(num = 0)
		@E = Hash.new
		@V = Array.new
		@V_H = Array.new
		#@G = Array.new(num, Array.new(num, 0))
		@G = nil
		
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
		#create()
	end

	def crypt_matrix()
		if(@rsa_n.nil? or @rsa_e.nil?)
			@rsa_e, @rsa_d, @rsa_n = key_gen(@bits)
			puts "KEYGEN"
		end
		@F = clone(@H_)
		@F.keys.each do |i|
			@F[i].keys.each {|j| @F[i][j] = exp(@F[i][j], @rsa_e, @rsa_n)}
		end
	end

	def get_encrypted_graph()
		pack(@F)
	end

	def get_encoded_graph()
		pack(@H_)
	end

	def get_translate_array()
		@translate_array.to_s
	end

	def get_encoded_path()
		out = Array.new
		(@V_H.size - 1).times do |i|
			out.push @V_H[i]		#e1
			out.push @V_H[i]		#e2
			out.push @H_[@V_H[i]][@V_H[i+1]]	#e
		end
		puts "PATH"
		puts out.to_s
		out.to_s
	end

	def check_encoded_path(str)
		str.sub!(/^./, '')
		str.sub!(/.$/, '')
		str.gsub!(',', '')
		data = str.split ' '
		data.map! {|i| i.to_i}
		puts 'data'
		puts data.to_s
		k=0
		e1 = Array.new
		e2 = Array.new
		e = Array.new
		num = data.size/3
		(num).times do 
			e1.push data.shift
			e2.push data.shift
			e.push data.shift
			k+=3
		end
		puts e.to_s
		v = e1.clone
		v.push e2[-1]
		puts "first check"
		#m_print(@F, 'FFFFUUU')
		puts v.to_s
		puts @F.keys.to_s
		return false if v.size != @F.keys.size
		v.uniq!
		puts "second check"
		return false if v.size != @F.keys.size
		#puts '============'
		e.map! {|i| exp(i, rsa_e, rsa_n)}
		num.times do |i|
			#puts e[i]
			#puts @F[e1[i]][e2[i]]
			puts "third check"
			return false if @F[e1[i]][e2[i]] != e[i]
		end
		true
	end

	def set_translate_array(str)
		str.sub!(/^./, '')
		str.sub!(/.$/, '')
		str.gsub!(',', '')
		@translate_array = str.split ' '
		@translate_array.map! {|i| i.to_i}
	end

	def set_encrypted_graph(str)
		puts "set_encrypted_graph"
		@F = nil
		@F_ = nil
		#m_print(@F, "F") unless @F.nil?
		@F = unpack(str)
		#m_print(@F, "F")
	end

	def set_encoded_graph(str)
		puts "set_encoded_graph"
		@H_ = unpack(str)
		m_print(@H_, 'new H_:')
	end

	def check_isomorphic_graph()
		puts "check_isomorphic_graph"
		@F_ = clone(@F)
		crypt_matrix()
		puts "first check"
		# puts @rsa_e
		# puts @rsa_n
		# puts @F
		# puts @F_
		return false unless cmp_matrix(@F, @F_)

		puts '==='
		decode_matrix()
		@H_clone = clone(@H)
		if(@G.nil?)
			@G = clone(@H)
			gen_isomorphic_graph(1)
			@G = clone(@H)
			@H = nil
			@H_ = nil
			#@G = nil
		else
			@G_clone = clone(@G)
			@G = clone(@H)
			gen_isomorphic_graph(1)
			@G = @G_clone
			puts "second check"
			return false if cmp_matrix(@H, @G_clone)
		end
		true
	end





	def pack(m)
		v = m.keys
		v.unshift m.keys.size
		m.keys.each do |i|
			m[i].keys.each {|j| v.push m[i][j]}
		end
		#puts v.to_s
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
		#m_print(@H_)
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
		#m_print(@H)
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
		@G = Hash.new
		1.upto(@n) do |i|
			@G[i] = Hash.new
			1.upto(@n) {|j| @G[i][j] = 0}
		end
		generate_path()
		gen_random_path()
		gen_isomorphic_graph()
		code_matrix()
		crypt_matrix()
		m_print(@G, 'G:')
		m_print(@H, 'H:')
		m_print(@H_, 'H_:')
		#m_print(@F, 'F:')
		#decode_matrix()
		#puts gam_chech(@H, @V_H)
		#puts cmp_matrix(unpack(pack(@H)), @H)
		#puts check_encoded_path(get_encoded_path())
	end

	def renew()
		@V_H = Array.new
		gen_isomorphic_graph()
		code_matrix()
		crypt_matrix()

		m_print(@G, 'G:')
		m_print(@H, 'H:')
		m_print(@H_, 'H_:')
		#m_print(@F, 'F:')
		puts @rsa_e
		puts @rsa_n
	end

	def gen_isomorphic_graph(inverse_ = nil)
		@translate_array = (1..@n).entries.shuffle if inverse_.nil?
		translate_hash = Hash.new
		1.upto(@n) do |i|
			translate_hash[i] = @translate_array[i-1]
		end
		translate_hash.invert unless inverse_.nil?
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

		#m_print(@H)
		#puts gam_chech(@H, @V_H)
		#puts translate_hash.to_s
	end

	def generate_path()
		@V = (1..@n).entries.shuffle
		#puts @V.to_s
		(@V.size - 1).times do |i|
			e1 = @V[i]
			e2 = @V[i+1]
			mark_path(e1, e2)
		end
		#m_print(@G)
		#puts gam_chech(@G, @V)
	end

	def gen_random_path()
		n = 1
		@n.downto(@n - 2) {|i| n += i}
		n.times do |i|
			e1 = rand(1..@n)
			e2 = rand(1..@n)
			mark_path(e1, e2)
		end
		#m_print(@G)
		#puts gam_chech(@G, @V)
		#puts n
	end

	def mark_path(e1, e2)
		# puts @G
		# puts @G.class
		# puts @G[e1].class
		# puts @G[e1][e2].class
		@G[e1][e2] = 1
		@G[e2][e1] = 1
	end

	def m_print(m, str=nil)
		puts str
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
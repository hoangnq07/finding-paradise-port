class NilClass
	def id
		4
	end
	def type
		"NilClass"
	end
end

class Hash
	def index(*args)
		key(*args)
	end
end

class Array
	def to_s
		return self.join
	end
end

unless defined?(Fixnum)
	Fixnum = Integer
end

unless defined?(Bignum)
	Bignum = Integer
end

if defined?(Font)
	Font.default_name = ["Open Sans", "Arial", "Times New Roman", "Tahoma"]
end

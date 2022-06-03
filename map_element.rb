class	MapElement
	attr_reader :position, :layer, :id, :solid
	
	def initializer(position, id, solid, layer = 10)
		@position = position
		@id = id
		@layer = layer
		@solid = solid
	end

end
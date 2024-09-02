@tool
extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	init_mesh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func init_mesh():
	
	var vertices = PackedVector3Array()
	create_base_mesh(100,100,vertices,0)

#add x * z points to a packed vector 3 array to make a flat plane
func create_base_mesh(x_max,z_max,array,y_coordinate=0):
	x_max = x_max+1 # need to create one more edge than the requested number of squares to ensure the final sqaure is complete
	#var noise = FastNoiseLite.new()
	#noise.noise_type = FastNoiseLite.TYPE_CELLULAR #(just curious about outputs)
	#noise.seed = 1
	var pipeline = [
		func (pos): apply_vertical_shift(pos,1),
		]
	
	#The triangle strip primitive connects the next point to the previous two vertecies to form a triangle
	#therefore to create one line of squares you need to make a series of vertical lines, these will be connected by the diagonal lines |\|\|\|\|\|
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for z in z_max:
		for x in x_max:
			st.set_normal(Vector3(0, 0, 1))
			st.set_uv(Vector2(0, 0))
			st.add_vertex(run_pipeline(Vector3(x, 0, z+1)))

			st.set_normal(Vector3(0, 0, 1))
			st.set_uv(Vector2(0, 1))
			st.add_vertex(run_pipeline(Vector3(x, 0, z)))
	# Commit changes to a mesh.
	st.generate_tangents()
	mesh = st.commit()

#add the amplitude of a sin wave to the y height of the current coorindate, multiplied by amplitude, accounting for the angle of the wave
func apply_sin(grid_pos, wave_amplitude = 1 , wave_frequency = 1, wave_angle = 0) -> Vector3:
	return Vector3.INF

#add the intensity of perlin noise at coordinate x,z to the y height of the given grid pos
func apply_perlin_noise(grid_pos,seed) -> Vector3:
	return Vector3.INF

#apply a constant vertical shift to the y coordinate of the given point
func apply_vertical_shift(grid_pos, shift = 0) -> Vector3:
	return Vector3.INF
	
#run all of the functions in the pipleine on the specified coordinate and return the coordinate with the updated y value
func run_pipeline(coordinate,pipeline = []) -> Vector3:
	return Vector3.INF

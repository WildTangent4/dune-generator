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
	var general_noise_map = FastNoiseLite.new()
	general_noise_map.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	general_noise_map.seed = 1
	general_noise_map.frequency = 0.005
	general_noise_map.fractal_octaves = 1
	general_noise_map.fractal_gain = 1
	
	var dune_noise_map = FastNoiseLite.new()
	dune_noise_map.noise_type = FastNoiseLite.TYPE_CELLULAR
	dune_noise_map.seed = 2
	dune_noise_map.frequency = 0.005
	dune_noise_map.fractal_octaves = 3
	dune_noise_map.fractal_gain = 2
	
	var biome_noise_map = FastNoiseLite.new()
	biome_noise_map.noise_type = FastNoiseLite.TYPE_CELLULAR
	biome_noise_map.seed = 2
	biome_noise_map.frequency = 0.01
	biome_noise_map.fractal_octaves = 3
	biome_noise_map.fractal_gain = 1
	var pipeline = [
		func (pos): return apply_vertical_shift(pos,8),
		func (pos): return apply_noise(pos,biome_noise_map,20),
		func (pos): return apply_sin(pos,1,0.2,45),
		func (pos): return apply_sin(pos,1,0.3,20),
		func (pos): return apply_sin(pos,4,0.1,0),
		func (pos): return apply_sin(pos,4,0.1,30),
		func (pos): return apply_sin(pos,0.2,0.6,63), #Smaller sin waves with high frequencies give the appearance of water
		func (pos): return apply_sin(pos,0.1,1,35),
		func (pos): return apply_clamp(pos,0,0.8),
		]
	
	
	#The triangle strip primitive connects the next point to the previous two vertecies to form a triangle
	#therefore to create one line of squares you need to make a series of vertical lines, these will be connected by the diagonal lines |\|\|\|\|\|
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	for z in z_max:
		if z%2==0:
			for x in range(x_max,-1,-1): #in the range() function, first parameter is inclusive and the second is exclusive, so we use -1 to get the correct range
				st.set_normal(Vector3(0, 0, 1))
				st.set_uv(Vector2(0, 0))
				st.add_vertex(run_pipeline(Vector3(x, 0, z),pipeline))
				
				st.set_normal(Vector3(0, 0, 1))
				st.set_uv(Vector2(0, 1))
				st.add_vertex(run_pipeline(Vector3(x, 0, z+1),pipeline))
		else:
			for x in range(0,x_max,1):
				#note, this has to be done this way to ensure that the generated triangles face upwards by forcing a clockwise winding order
				st.set_normal(Vector3(0, 0, 1))
				st.set_uv(Vector2(0, 0))
				st.add_vertex(run_pipeline(Vector3(x, 0, z),pipeline))

				st.set_normal(Vector3(0, 0, 1))
				st.set_uv(Vector2(0, 1))
				st.add_vertex(run_pipeline(Vector3(x+1, 0, z),pipeline))
				
				st.set_normal(Vector3(0, 0, 1))
				st.set_uv(Vector2(0, 0))
				st.add_vertex(run_pipeline(Vector3(x, 0, z+1),pipeline))

				st.set_normal(Vector3(0, 0, 1))
				st.set_uv(Vector2(0, 1))
				st.add_vertex(run_pipeline(Vector3(x+1, 0, z+1),pipeline))
			
	# Commit changes to a mesh.
	st.generate_tangents()
	st.generate_normals()
	mesh = st.commit()
	
#add the amplitude of a sin wave to the y height of the current coorindate, multiplied by amplitude, accounting for the angle of the wave
func apply_sin(grid_pos, wave_amplitude = 1 , wave_frequency = 1, wave_angle = 45) -> Vector3:
	var shift = calculate_angular_shift(grid_pos.z,wave_angle)
	return Vector3(
		grid_pos.x,
		grid_pos.y+(sin((grid_pos.x + shift) * wave_frequency) * wave_amplitude),
		grid_pos.z
		)

#add the intensity of perlin noise at coordinate x,z to the y height of the given grid pos
func apply_noise(grid_pos,noise, amplitude = 1) -> Vector3:
	#print(noise.get_noise_2d(grid_pos.x,grid_pos.z))
	return Vector3(
		grid_pos.x,
		grid_pos.y+(noise.get_noise_2d(grid_pos.x,grid_pos.z) * amplitude),
		grid_pos.z
		)

#apply a constant vertical shift to the y coordinate of the given point
func apply_vertical_shift(grid_pos, shift = 1) -> Vector3:
	return Vector3(
		grid_pos.x,
		grid_pos.y+shift,
		grid_pos.z
		)

#run all of the functions in the pipleine on the specified coordinate and return the coordinate with the updated y value
#ALL FUNCTIONS MUST TAKE POSITION AS FIRST VALUE
func run_pipeline(coordinate,pipeline = []) -> Vector3:
	for functor in pipeline:
		coordinate = functor.call(coordinate)
	return coordinate #warning no error handling if returns nil

# moves positions below the threshold value towards the value, proportional to distance from the desired height
#TODO: create variant of this function that applies the clamp relative to the weight on a noise map (simulating biomes)
func apply_clamp(grid_pos, threshold, clamping_force):
	if grid_pos.y<threshold:
		grid_pos = Vector3(
		grid_pos.x,
		grid_pos.y+ ((threshold-grid_pos.y)*clamping_force),
		grid_pos.z
		)
	return grid_pos

#normal clamp function, but uses the noise map provided as a mask to calculate clamping force
func apply_noise_based_clamp(grid_pos, threshold, noise):
	if grid_pos.y<threshold:
		var clamping_force = noise.get_noise_2d(grid_pos.x,grid_pos.z)
		grid_pos = Vector3(
		grid_pos.x,
		grid_pos.y+ ((threshold-grid_pos.y)*clamping_force),
		grid_pos.z
		)
	return grid_pos

func apply_pointy_sin_wave(grid_pos, wave_amplitude = 1 , wave_frequency = 1, wave_angle = 45, shift = 1) -> Vector3:
	shift = shift + calculate_angular_shift(grid_pos.z,wave_angle)
	var power = 3
	return Vector3(
		grid_pos.x,
		grid_pos.y+(pow(sin((grid_pos.x + shift) * wave_frequency),power) * wave_amplitude),
		grid_pos.z
		)

#for rotated waves, apply a rotation to the x coordinate that is being calculated for
func calculate_angular_shift(x_pos,roation_deg):
	return x_pos*tanh(deg_to_rad(roation_deg))

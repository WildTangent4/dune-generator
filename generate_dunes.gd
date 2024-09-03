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
	var cellular_noise = FastNoiseLite.new()
	cellular_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH #(just curious about outputs)
	cellular_noise.seed = 1
	cellular_noise.frequency = 0.005
	cellular_noise.fractal_octaves = 1
	cellular_noise.fractal_gain = 1
	var pipeline = [
		#func (pos): return apply_vertical_shift(pos,-1),#hardcode values here to customise the pipeline
		func (pos): return apply_noise(pos,cellular_noise,2),
		func (pos): return apply_sin(pos,1,0.2,45),
		func (pos): return apply_sin(pos,1,0.3,20),
		func (pos): return apply_sin(pos,4,0.1,0),
		func (pos): return apply_sin(pos,0.2,0.6,63),
		func (pos): return apply_sin(pos,0.1,1,35),
		func (pos): return apply_clamp(pos,-3,0.9),
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
func apply_clamp(grid_pos, threshold, clamping_force):
	if grid_pos.y<threshold:
		grid_pos = Vector3(
		grid_pos.x,
		grid_pos.y+ ((threshold-grid_pos.y)*clamping_force),
		grid_pos.z
		)
	return grid_pos
	
#for rotated waves, apply a rotation to the x coordinate that is being calculated for
func calculate_angular_shift(x_pos,roation_deg):
	return x_pos*tanh(deg_to_rad(roation_deg))

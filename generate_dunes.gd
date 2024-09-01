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
	create_base_mesh(3,1,vertices,0)

#add x * z points to a packed vector 3 array to make a flat plane
func create_base_mesh(x_max,z_max,array,y_coordinate=0):
	x_max = x_max+1 # need to create one more lines than the requested number of squares
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	#create a quad from two tris

	#create top right triangle

	#The triangle strip primitive connects the next point to the previous two vertecies to form a triangle
	#therefore to create one line of squares you need to make a series of vertical lines, these will be connected by the diagnoal lines |\|\|\|\|\|
	var y_max = z_max
	for y in y_max:
		for x in x_max:
		#create straight edge
			st.set_normal(Vector3(0, 0, 1))
			st.set_uv(Vector2(0, 0))
			st.add_vertex(Vector3(0, y, x))

			st.set_normal(Vector3(0, 0, 1))
			st.set_uv(Vector2(0, 1))
			st.add_vertex(Vector3(0, y+1, x))

	
	# Commit to a mesh.
	#st.generate_normals()
	st.generate_tangents()
	mesh = st.commit()
	

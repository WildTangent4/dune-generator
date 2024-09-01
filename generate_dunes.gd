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
	create_base_mesh(2,2,vertices,0)

#add x * z points to a packed vector 3 array to make a flat plane
func create_base_mesh(x_max,z_max,array,y_coordinate=0):
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	#create a quad from two tris

	#create top right triangle

	#The triangle strip primitive connects the next point to the previous two vertecies to form a triangle
	#therefore to create one line of squares you need to make a series of vertical lines, these will be connected by the diagnoal lines |\|\|\|\|\|

	for i in 10:
		#create straight edge
		st.set_normal(Vector3(0, 0, 1))
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(0, 0, i))

		st.set_normal(Vector3(0, 0, 1))
		st.set_uv(Vector2(0, 1))
		st.add_vertex(Vector3(0, 1, i))

		

	
	# Commit to a mesh.
	st.generate_normals()
	st.generate_tangents()
	mesh = st.commit()
	

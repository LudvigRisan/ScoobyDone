extends MeshInstance3D
class_name DebugLiner

var vertices: PackedVector3Array
var arrayMesh: ArrayMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arrayMesh = mesh as ArrayMesh

func drawLine(a: Vector3, b: Vector3):
	vertices.append(a)
	vertices.append(b)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	arrayMesh.clear_surfaces()
	var arrays: Array
	arrays.resize(arrayMesh.ARRAY_MAX)
	arrays[arrayMesh.ARRAY_VERTEX] = vertices
	
	#arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	vertices.clear()
	
	

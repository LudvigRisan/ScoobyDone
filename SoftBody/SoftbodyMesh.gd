extends MeshInstance3D

@export
var tension: float = 0.3
@export
var dampening: float = 0.2
@export
var physicsPrefab: PackedScene

var vertices: PackedVector3Array
var normals: PackedVector3Array
var uvs: PackedVector2Array
var indices: PackedInt32Array

var arrayMesh: ArrayMesh

var offsets: PackedFloat32Array
var offsetIndices: PackedInt32Array

var orbs: Array[RigidBody3D]

func _ready() -> void:
	arrayMesh = mesh as ArrayMesh
	
	var arrays: Array = arrayMesh.surface_get_arrays(0)
	
	vertices = arrays[arrayMesh.ARRAY_VERTEX]
	normals = arrays[arrayMesh.ARRAY_NORMAL]
	uvs = arrays[arrayMesh.ARRAY_TEX_UV]
	indices = arrays[arrayMesh.ARRAY_INDEX]
	
	for i in range(0, indices.size(), 3):
		tryAddOffset(i, i + 1)
		tryAddOffset(i, i + 2)
		tryAddOffset(i + 1, i + 2)
	

func tryAddOffset(a: int, b: int) -> void:
	for i in range(0, offsetIndices.size(), 2):
		if (a == offsetIndices[i] and b == offsetIndices[i + 1])\
		or (a == offsetIndices[i + 1] and b == offsetIndices[i]):
			return
	
	offsetIndices.append(indices[a])
	offsetIndices.append(indices[b])
	offsets.append(vertices[indices[a]].distance_to(vertices[indices[b]]))

func hooke(deviation: float, velocity: float) -> float:
	return (tension * deviation) - (dampening * velocity)

func calculateForce(a: int, b: int, offset: float, delta: float) -> void:
	var deviation: float = vertices[a].distance_to(vertices[b]) - offset
	var force: Vector3 = hooke(deviation,  0) * vertices[a].direction_to(vertices[b])
	vertices[a] += force * delta
	vertices[b] -= force * delta

func _process(delta: float) -> void:
	for i in range(0, offsetIndices.size(), 2):
		calculateForce(offsetIndices[i], offsetIndices[i + 1], offsets[i * 0.5], delta)
	
	var arrays: Array
	arrays.resize(arrayMesh.ARRAY_MAX)
	arrays[arrayMesh.ARRAY_VERTEX] = vertices
	arrays[arrayMesh.ARRAY_NORMAL] = normals
	arrays[arrayMesh.ARRAY_TEX_UV] = uvs
	arrays[arrayMesh.ARRAY_INDEX] = indices
	
	arrayMesh.clear_surfaces()
	arrayMesh.add_surface_from_arrays(arrayMesh.PRIMITIVE_TRIANGLES, arrays)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		for i in range(vertices.size()):
			vertices[i] += Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
		print("boop")

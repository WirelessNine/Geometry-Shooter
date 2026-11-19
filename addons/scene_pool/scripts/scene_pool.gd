@icon("uid://duy0ckgvdiu83")
class_name ScenePool
extends RefCounted
##Container for a pool of scenes.

##Emitted if a new scene is created when requesting or updating.
signal scene_created
##Emitted if a new scene is created when requested. Only works with access mode [b]Dynamic[/b].
signal scene_requested(node: Node)
##Emitted if a new scene is created when returned. Only works with access mode [b]Dynamic[/b].
signal scene_returned(node: Node)


##Defines how the pool is accessed and managed.
enum AccessMode {
	##Nodes are taken and returned from the [member inactive] individually, when needed.
	DYNAMIC,
	##Nodes are never taken from the [member inactive], instead, they are updated in order, the used ones are enabled (requested), and the unused ones are disabled (returned).
	BATCHED,
}

##The inactive access mode.
var access_mode: AccessMode = AccessMode.DYNAMIC
##The packed scene instantiated for in the inactive.
var packed_scene: PackedScene
##The parent node of all scenes created.
var parent: Node

##[Callable] called when a scene is instantiated.
var on_created: Callable
##[Callable] called when a scene is requested.
var on_requested: Callable
##[Callable] called when a scene is returned.
var on_returned: Callable

##[Array] of all scenes that are inactive.
var inactive: Array[Node]

##[Dictionary] of all scenes that are active.
var active: Dictionary[Node, bool]


func _init(
	p_access_mode: AccessMode,
	p_packed_scene: PackedScene,
	p_parent: Node,
	p_start_scenes: int = 0,
	p_on_created: Callable = _on_returned,
	p_on_requested: Callable = _on_requested,
	p_on_returned: Callable = _on_returned,
) -> void:
	access_mode = p_access_mode
	packed_scene = p_packed_scene
	parent = p_parent
	on_created = p_on_created
	on_requested = p_on_requested
	on_returned = p_on_returned

	create_scene(p_start_scenes)


func _to_string() -> String:
	return "ScenePool of %s" % packed_scene


##Instatiates scenes based on the amount of [param instances].
func create_scene(instances: int) -> void:
	if instances <= 0:
		return

	for x: int in instances:
		inactive.append(_instantiate_scene())


##Requests a single scene from the [member inactive] and returns it if possible. Only for Dynamic access mode.
func request_scene() -> Node:
	if not access_mode == AccessMode.DYNAMIC:
		push_error("access_mode is not DYNAMIC!")
		return null

	if is_pool_exhausted():
		create_scene(1)

	var node: Node = inactive.pop_back()
	active[node] = true

	on_requested.call(node)
	scene_requested.emit(node)

	return node


##Returns the [param node] back to the [member inactive]. Only for Dynamic access mode.
func return_scene(node: Node) -> void:
	if node == null:
		return

	if not access_mode == AccessMode.DYNAMIC:
		push_error("access_mode is not DYNAMIC!")
		return

	if not node in active:
		push_error(node, " is not active or part of the pool!")
		return

	inactive.append(node)
	active.erase(node)

	on_returned.call(node)

	scene_returned.emit(node)


##Calls the [param method] for each scene in the pool, with items from the [param array].[br]
##The first parameter should be the scene/node, and the second one the item from the [param array].
func update_scenes(array: Array, method: Callable) -> void:
	if not access_mode == AccessMode.BATCHED:
		push_error("access_mode is not BATCHED!")
		return

	var array_size: int = array.size()
	var pool_size: int = inactive.size()

	if array_size > pool_size:
		create_scene(array_size - pool_size)
	elif array_size < pool_size:
		for x: int in range(array_size, pool_size):
			on_returned.call(inactive[x])

	for x: int in array_size:
		var item: Variant = array[x]
		var node: Node = inactive[x]

		on_requested.call(node)

		method.call(node, item)


##Returns [code]true[/code] if [param node] is active.
func is_scene_active(node: Node) -> bool:
	return node in active


##Returns the total amount inactive and active scenes pooled
func get_pool_size() -> int:
	return inactive.size() + active.size()


##Returns [code]true[/code] if all scenes are active.
func is_pool_exhausted() -> bool:
	return inactive.is_empty()


func _on_requested(node: Node) -> void:
	if node is CanvasItem:
		node.show()


func _on_returned(node: Node) -> void:
	if node is CanvasItem:
		node.hide()


func _instantiate_scene() -> Node:
	var node: Node = packed_scene.instantiate()
	parent.add_child.call_deferred(node)

	on_created.call(node)

	return node

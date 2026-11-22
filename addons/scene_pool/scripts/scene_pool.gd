@icon("uid://duy0ckgvdiu83")
class_name ScenePool
extends RefCounted
##Container for a pool of scenes.
##
##Container for a pool of scenes. A ScenePool manages object pooling for instances of a packed scene very simple. It reuses scenes instead of instatiating and freeing them which improves performance and reduces memory fragmentation.

##Emitted if a new scene is created.
signal scene_created(scene: Node)
##Emitted if a new scene is created when requested. Only works with access mode [b]Dynamic[/b].
signal scene_requested(scene: Node)
##Emitted if a new scene is created when returned. Only works with access mode [b]Dynamic[/b].
signal scene_returned(scene: Node)

##Defines how the pool is accessed and managed.
enum AccessMode {
	##Inactive scenes are taken and returned individually, when needed.
	DYNAMIC,
	##Scenes are are updated in order, the used ones are enabled, and the unused ones are disabled.
	BATCHED,
}

##The name of the metadata that stores the [ScenePool] of a scene.
const META_NAME: StringName = &"pool"

##The access mode for scenes.
var access_mode: AccessMode = AccessMode.DYNAMIC
##The packed scene instantiated and pooled.
var packed_scene: PackedScene
##The node where instatiated scenes are parented.
var parent: Node

##The method called when a scene is instantiated.
var on_created: Callable
##The method called when a scene is requested.
var on_requested: Callable
##The method called when a scene is returned.
var on_returned: Callable

##The list of scenes that are inactive.
var inactive: Array[Node]

##The list of scenes scenes that are active.
var active: Dictionary[Node, bool]


##Returns the [ScenePool] that [param scene] is part of.
static func get_owner_pool(scene: Node) -> ScenePool:
	if not scene:
		push_error(scene, " is not valid.")
		return

	if not scene.has_meta(META_NAME):
		push_error(scene, " is not part of a ScenePool.")
		return null

	return scene.get_meta(META_NAME)


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

	if is_instance_valid(p_parent):
		parent.tree_exiting.connect(clear_pool)


func _to_string() -> String:
	return "ScenePool of %s" % packed_scene


##Instatiates scenes based on the amount of [param instances].
func create_scene(instances: int) -> void:
	if instances <= 0:
		return

	for x: int in instances:
		inactive.append(_instantiate_scene())


##Requests a scenes and returns it. [br]
##[important]: This method only works for Dynamic access mode.
func request_scene() -> Node:
	if not access_mode == AccessMode.DYNAMIC:
		push_error("access_mode is not DYNAMIC!")
		return null

	if is_pool_exhausted():
		create_scene(1)

	var scene: Node = inactive.pop_back()
	active[scene] = true

	on_requested.call(scene)
	scene_requested.emit(scene)

	return scene


##Makes the [param scene] inactive. [br]
##[important]: This method only works for Dynamic access mode.
func return_scene(scene: Node) -> void:
	if scene == null:
		return

	if not access_mode == AccessMode.DYNAMIC:
		push_error("access_mode is not DYNAMIC!")
		return

	if not is_scene_active(scene):
		return

	inactive.append(scene)
	active.erase(scene)

	on_returned.call(scene)

	scene_returned.emit(scene)


##Calls the [param method] for each scene in the pool, with elements from the [param items] array.[br]
##[note]: The first parameter is the scene, and the second the item. [br]
##[important]: This method only works for Batched access mode.
func update_scenes(items: Array, method: Callable) -> void:
	if not access_mode == AccessMode.BATCHED:
		push_error("access_mode is not BATCHED!")
		return

	var array_size: int = items.size()
	var pool_size: int = inactive.size()

	if array_size > pool_size:
		create_scene(array_size - pool_size)
	elif array_size < pool_size:
		for x: int in range(array_size, pool_size):
			on_returned.call(inactive[x])

	for x: int in array_size:
		var item: Variant = items[x]
		var node: Node = inactive[x]

		on_requested.call(node)

		method.call(node, item)


##Force returns all scenes that are currently active.
func return_all_scenes() -> void:
	for x: Node in active.keys():
		if not is_instance_valid(x):
			continue

		return_scene(x)


##Frees and clears all scenes pooled.
func clear_pool() -> void:
	return_all_scenes()

	for x: Node in inactive:
		if not is_instance_valid(x):
			continue

		x.queue_free()

	inactive.clear()
	active.clear()


##Returns [code]true[/code] if [param scene] is active.
func is_scene_active(scene: Node) -> bool:
	return scene in active


##Returns the total amount inactive and active scenes pooled
func get_pool_size() -> int:
	return inactive.size() + active.size()


##Returns [code]true[/code] if all scenes are active.
func is_pool_exhausted() -> bool:
	return inactive.is_empty()


##Default method called when a scene is requested.
func _on_requested(scene: Node) -> void:
	if scene is CanvasItem:
		scene.show()


##Default method called when a scene is returned.
func _on_returned(scene: Node) -> void:
	if scene is CanvasItem:
		scene.hide()


##Instantiates a new scene.
func _instantiate_scene() -> Node:
	var scene: Node = packed_scene.instantiate()
	parent.add_child.call_deferred(scene)

	_add_pool_reference(scene)

	on_created.call(scene)
	scene_created.emit(scene)

	return scene


##Adds a meta reference of the pool to [param scene].
func _add_pool_reference(scene: Node) -> void:
	scene.set_meta(META_NAME, self)

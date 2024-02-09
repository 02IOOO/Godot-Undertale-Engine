extends Node

@export_file("*.tscn") var default_scene: String
@onready var Blinder: ColorRect = $Blinder
var overworld_scene: Overworld


const blind_time: float = 0.5

var data := {
	entrance = null,
	direction = Vector2i.DOWN,
}

var data_default := data.duplicate()

func _ready() -> void:
	Blinder.modulate.a = 0

func enter_room_default() -> void:
	Global.overworld_data.room = default_scene
	var tw := create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(Blinder, "modulate:a", 1, blind_time)
	await tw.finished
	_load_and_set_scene(default_scene)

	
func enter_room_path(room_path: String, extra_data: Dictionary = {}) -> void:
	data.merge(extra_data, true)
	var tw := create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(Blinder, "modulate:a", 1, blind_time)
	await tw.finished
	_load_and_set_scene(room_path)

func _load_and_set_scene(path: String) -> void:
	var resource: Object
	if ResourceLoader.exists(path):
		resource = load(path)
	else:
		resource = load(default_scene)
	if !resource is PackedScene:
		Global.overworld_data.room = default_scene
		resource = load(default_scene)
	else:
		Global.overworld_data.room = path
	resource = resource.instantiate()
	var current_scene: Node = get_tree().current_scene
	get_tree().unload_current_scene()
	get_tree().root.add_child(resource)
	get_tree().current_scene = resource
	
	_set_player_data(resource)

func _set_player_data(current_scene: Node) -> void:
	if current_scene is Overworld:
		current_scene.data = data
		current_scene.room_init()
	Global.player_can_move = true
	Global.player_in_menu = false
	data = data_default.duplicate()
	var tw := create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(Blinder,"modulate:a",0,blind_time)

func load_cached_overworld_scene() -> void:
	Blinder.modulate.a = 1
	var tw := create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(Blinder, "modulate:a", 0, blind_time)
	Global.player_can_move = true
	Global.player_in_menu = false
	var tree := get_tree()
	tree.unload_current_scene()
	var sc: Node = overworld_scene if overworld_scene else load(default_scene).instantiate()
	tree.root.add_child(sc)
	tree.current_scene = sc

func load_battle(
				battle_scene_path: String = "res://Battle/battle.tscn",
				battle_resource: Encounter = preload("res://Resources/Encounters/EncounterTest.tres"),
				transistion := true, to_position := Vector2(48, 452)
			) -> void:
	var tree := get_tree()
	var screen: Node
	if transistion:
		screen = preload("res://Overworld/battle_transistion.tscn").instantiate()
		screen.target = to_position
		tree.current_scene.add_child(screen)
		await screen.transistion()
	Global.player_in_menu = false
	Global.player_can_move = true
	var battle: Node = load(battle_scene_path).instantiate()
	battle.encounter = battle_resource
	overworld_scene = tree.current_scene
	tree.root.remove_child(overworld_scene)
	tree.root.add_child(battle)
	tree.current_scene = battle

func load_general_scene(scene_path: String, transistion := true):
	var tree := get_tree()
	if transistion:
		@warning_ignore("confusable_local_declaration")
		var tw := create_tween().set_trans(Tween.TRANS_QUAD)
		tw.tween_property(Blinder, "modulate:a", 1, blind_time)
		await tw.finished
	Global.player_in_menu = false
	Global.player_can_move = true
	var scene: Node = load(scene_path).instantiate()
	overworld_scene = tree.current_scene
	tree.root.remove_child(overworld_scene)
	tree.root.add_child(scene)
	tree.current_scene = scene
	var tw := create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(Blinder, "modulate:a", 0, blind_time)

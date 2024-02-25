extends Node

@export_file("*.tscn") var default_scene: String
@onready var Blinder: ColorRect = $Blinder
var overworld_scene: Overworld

const DEFAULT_BATTLE := "res://Battle/battle.tscn"

const blind_time: float = 0.4

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
	var resource: PackedScene
	if ResourceLoader.exists(path):
		resource = load(path)
	else:
		resource = load(default_scene)
	if !resource is PackedScene:
		Global.overworld_data.room = default_scene
		resource = load(default_scene)
	else:
		Global.overworld_data.room = path
	var node := resource.instantiate()
	get_tree().unload_current_scene()
	get_tree().root.add_child(node)
	get_tree().current_scene = node

	_set_player_data.call_deferred(node)

func _set_player_data(current_scene: Node) -> void:
	if current_scene is Overworld:
		current_scene.room_init(data)
	Global.player_can_move = true
	Global.player_in_menu = false
	data = data_default.duplicate()
	var tw := create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(Blinder, "modulate:a", 0, blind_time)

func load_cached_overworld_scene(transistion := true) -> void:
	Global.player_can_move = true
	Global.player_in_menu = false
	if transistion:
		var tw := create_tween().set_trans(Tween.TRANS_QUAD)
		tw.tween_property(Blinder, "modulate:a", 1, blind_time)
		tw.tween_property(Blinder, "modulate:a", 0, blind_time)
		await tw.step_finished
	var tree := get_tree()
	tree.unload_current_scene()
	var sc: Node = overworld_scene if overworld_scene else (load(default_scene) as PackedScene).instantiate()
	tree.root.add_child(sc)
	tree.current_scene = sc
	sc.request_ready()

func load_battle(
				battle_scene_path: String = DEFAULT_BATTLE,
				battle_resource: Encounter = preload("res://Resources/Encounters/EncounterTest.tres"),
				transistion := true, to_position := Vector2(48, 452)
			) -> void:
	var tree := get_tree()
	var screen: BattleTransistion
	if transistion:
		screen = preload("res://Overworld/battle_transistion.tscn").instantiate()
		screen.target = to_position
		tree.current_scene.add_child(screen)
		await screen.transistion()
	Global.player_in_menu = false
	Global.player_can_move = true
	var battle: Node = (load(battle_scene_path) as PackedScene).instantiate()
	battle.encounter = battle_resource
	overworld_scene = tree.current_scene
	tree.root.remove_child(overworld_scene)
	tree.root.add_child(battle)
	tree.current_scene = battle

func load_general_scene(scene_path: String, transistion := true):
	var tree := get_tree()
	if transistion:
		var tw := create_tween().set_trans(Tween.TRANS_QUAD)
		tw.tween_property(Blinder, "modulate:a", 1, blind_time)
		tw.tween_property(Blinder, "modulate:a", 0, blind_time)
		await tw.step_finished
	Global.player_in_menu = false
	Global.player_can_move = true
	var scene: Node = (load(scene_path) as PackedScene).instantiate()
	overworld_scene = tree.current_scene
	tree.root.remove_child(overworld_scene)
	tree.root.add_child(scene)
	tree.current_scene = scene
		

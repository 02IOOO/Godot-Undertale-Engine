extends Node2D
class_name Overworld

@export var world_name := "overworld room"
@export var player_path := ^"YSortNodes/TileMap/PlayerOverworld"
@export var camera_path := ^"YSortNodes/TileMap/PlayerOverworld/Camera"
#@export var music_player := ^"music"
@export var music: AudioStream = preload("res://Musics/default2.wav")
@export var room_entrances: Array[Vector2] = []
@onready var Player: PlayerOverworld = get_node(player_path)
@onready var Camera: Node = get_node(camera_path)
@onready var Music: AudioStreamPlayer = Global.Music #get_node(music_player)

var text_box: PackedScene = preload("res://Overworld/text_box.tscn")

var data := {
	
}

func _on_saved() -> void:
	Global.overworld_data["room_pos"] = [Player.global_position.x, Player.global_position.y]


func _init() -> void:
	await ready
	Camera.blinder.modulate.a = 1
	Camera.blind(0.5, 0)
	var music_tween := get_tree().create_tween()
	Music.stream = music
	Music.play()
	Music.volume_db = -70
	music_tween.tween_property(Music, "volume_db", 0, 1).set_trans(Tween.TRANS_QUAD)

func room_init() -> void:
	if data.entrance != null and data.entrance >= 0 and room_entrances.size() > data.entrance:
		Player.position = room_entrances[data.entrance]
	Player.force_direction(data.direction)
	
	if Global.overworld_data.get("room_pos",[0.0, 0.0]) != [0.0, 0.0] and Global.just_died:
		Player.global_position = Vector2(Global.overworld_data["room_pos"][0], Global.overworld_data["room_pos"][1])
		Global.just_died = false
	
	if Global.overworld_temp_data.get("global_position"):
		Player.global_position = Global.overworld_temp_data["global_position"]
		Global.overworld_temp_data["global_position"] = Vector2.ZERO


func summontextbox() -> TextBox:
	var clone: Node = text_box.instantiate()
	add_child(clone)
	return clone


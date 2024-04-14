extends Node2D

@export var enemy_scenes : Array[PackedScene]

var turn = 0

func _ready():
	Bus.enemy_turn_ended.connect(on_enemy_turn_ended)
	
func on_enemy_turn_ended():
	turn += 0
	var new_enemy = enemy_scenes.pick_random().instantiate()
	add_sibling(new_enemy)
	new_enemy.global_position = global_position
	queue_free()

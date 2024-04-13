extends Node2D

@export var enemy_transform : PackedScene

func _ready():
	Bus.enemy_turn_ended.connect(on_enemy_turn_ended)

func on_enemy_turn_ended():
	var new_enemy = enemy_transform.instantiate()
	add_sibling(new_enemy)
	new_enemy.global_position = global_position
	queue_free()

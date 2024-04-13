extends Node2D

@export var spawn_scene : PackedScene

func _ready():
	Bus.enemy_turn_ended.connect(on_enemy_turn_ended)

func on_enemy_turn_ended():
	spawn_enemy()
	
func random_spawn_point():
	var rect : Rect2 = get_viewport().get_visible_rect()
	return Vector2(randf_range(rect.position.x, rect.end.x), randf_range(rect.position.y, rect.end.y))

func spawn_enemy():
	var new_enemy = spawn_scene.instantiate()
	new_enemy.global_position = random_spawn_point()
	add_child(new_enemy)
	

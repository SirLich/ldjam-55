extends Node2D

@export var spawn_scene : PackedScene
@export var item_scene : PackedScene

var turn = 0

func get_num_spawns(n):
	return (n / 8) + 1
	
func should_spawn_item():
	return randf() < 0.3
	
func _ready():		
	Bus.enemy_turn_ended.connect(on_enemy_turn_ended)

func on_enemy_turn_ended():
	turn += 1
	for i in range(get_num_spawns(turn)):
		spawn_enemy()
	
	if should_spawn_item():
		spawn_item()
	
func random_spawn_point():
	var rect : Rect2 = get_viewport().get_visible_rect()
	return Vector2(randf_range(rect.position.x, rect.end.x), randf_range(rect.position.y, rect.end.y))

func spawn_enemy():
	var new_enemy = spawn_scene.instantiate()
	new_enemy.global_position = random_spawn_point()
	add_child(new_enemy)
	
func spawn_item():
	var new_enemy = item_scene.instantiate()
	new_enemy.global_position = random_spawn_point()
	add_child(new_enemy)
	

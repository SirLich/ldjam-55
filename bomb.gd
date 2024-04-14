extends Node2D

@onready var explode_animation = $AnimatedSprite2D
@onready var explode_player = $AudioStreamPlayer2D
@onready var explosion_area = $Area2D

var explode_damage = 10

func _ready():
	explode_player.play()
	explode_animation.play("explode")
	var tween = get_tree().create_tween()
	
	await get_tree().create_timer(0.2).timeout
	
	for body in explosion_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.damage(explode_damage)
	
	await get_tree().create_timer(1.8).timeout
	queue_free()

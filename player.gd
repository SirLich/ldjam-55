extends CharacterBody2D
class_name Player

@export var max_health : int =  100
var health


var move_time = 1.0
@export var movement_speed: float = 300.0
var dashing_speed: float = 600.0

@export var explode_radius : float = 100
@export var explode_damage : float = 10

@export var attack_radius : float = 75
@export var attack_angle = PI/2
@export var attack_speed = 0.3
@export var attack_damage : float = 20
var attack_width = 0.0
@export var agent : NavigationAgent2D
@export var action_debug_label : Label
@export var explosion_area : Area2D
@export var explosion_shape : CollisionShape2D
@export var sprite : AnimatedSprite2D
@export var health_area : Area2D

@export var attack_area = Area2D
@export var attack_shape = CollisionShape2D

@export var damage_player : AudioStreamPlayer2D
@export var move_player : AudioStreamPlayer2D
@export var attack_player : AudioStreamPlayer2D
@export var explode_player : AudioStreamPlayer2D

@export var explode_animation : AnimatedSprite2D

var move_distance

var action : PlayerAction

enum PlayerAction {
	NONE,
	MOVE,
	MOVING,
	EXPLODE,
	EXPLODING,
	ATTACK,
	ATTACKING,
	DASH,
	DASHING
}

func _ready():
	health = max_health
	explosion_shape.shape.radius = explode_radius
	Bus.enemy_turn_started.connect(on_enemy_turn_started)
	
	agent.navigation_finished.connect(on_navigation_finished)
	sprite.play("idle")

func on_enemy_turn_started(time):
	for body in health_area.get_overlapping_bodies():
		try_damage_player(body)
	
func on_navigation_finished():
	if is_action(PlayerAction.MOVING) or is_action(PlayerAction.DASHING):
		set_action(PlayerAction.NONE)
	
func is_action(in_action):
	return in_action == action
	
func set_action(in_action):
	if in_action is PlayerAction:
		action = in_action
	else:
		action = PlayerAction.get(in_action)
	
	action_debug_label.text = PlayerAction.find_key(action)
	
	if action == PlayerAction.MOVING or action == PlayerAction.DASHING:
		if action == PlayerAction.MOVING:
			Bus.perform_action.emit(PlayerAction.MOVE)
		else:
			Bus.perform_action.emit(PlayerAction.DASH)
			
		#agent.target_position = get_global_mouse_position()
		sprite.play("walk")
		move_player.play()
		
		#await get_tree().create_timer(move_time).timeout
		#if PlayerAction.MOVING or action == PlayerAction.DASHING:
			#set_action(PlayerAction.NONE)
	else:
		sprite.play("idle")
		move_player.stop()
		
	if action == PlayerAction.EXPLODING:
		Bus.perform_action.emit(PlayerAction.EXPLODE)
		perform_explosion()
		
	if action == PlayerAction.ATTACKING:
		Bus.perform_action.emit(PlayerAction.ATTACK)
		perform_attack()

func perform_attack():
	attack_player.play()
	attack_shape.shape.size.y = attack_radius + 45
	
	var start_angle = get_angle_to(get_global_mouse_position()) + PI/2
	
	
	var tween = get_tree().create_tween()
	attack_area.rotation = start_angle
	var attack_anim_speed = attack_speed / 2
	tween.tween_property(attack_area, "rotation", start_angle + attack_angle, attack_speed)
	var anim_tween = get_tree().create_tween()
	anim_tween.tween_property(self, "attack_width", PI/2, attack_anim_speed)
	anim_tween.tween_property(self, "attack_width", 0, attack_anim_speed)
	
	await tween.finished
	
	attack_shape.shape.size.y = 0
	if is_action(PlayerAction.ATTACKING):
		set_action(PlayerAction.NONE)
	
func perform_explosion():
	explode_player.play()
	explode_animation.play("explode")
	var tween = get_tree().create_tween()
	
	for body in explosion_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.damage(explode_damage)
		
	await get_tree().create_timer(2).timeout
	if is_action(PlayerAction.EXPLODING):
		set_action(PlayerAction.NONE)
	
func _input(event):
	if event.is_action_released("right_click"):
		set_action(PlayerAction.NONE)
	
	if event.is_action_released("left_click"):
		if is_action(PlayerAction.MOVE):
			move_distance = 200
			set_action(PlayerAction.MOVING)
		if is_action(PlayerAction.DASH):
			move_distance = 500
			set_action(PlayerAction.DASHING)
		if is_action(PlayerAction.ATTACK):
			set_action(PlayerAction.ATTACKING)
		if is_action(PlayerAction.EXPLODE):
			set_action(PlayerAction.EXPLODING)

func get_speed():
	if is_action(PlayerAction.MOVE) or is_action(PlayerAction.MOVING):
		return movement_speed
	if is_action(PlayerAction.DASH) or is_action(PlayerAction.DASHING):
		return dashing_speed

var custom_pos = false

func _draw():
	if is_action(PlayerAction.MOVE) or is_action(PlayerAction.DASH):
		var path = agent.get_current_navigation_path()
		var new_path : PackedVector2Array
		var size = 0
		var last_point = path[0]
		var colors : PackedColorArray
		for v in path:
			size += v.distance_to(last_point)
			
			var overshoot = size - get_speed()
			if size > get_speed():
				last_point = v.move_toward(last_point, abs(overshoot))
				new_path.append(last_point - global_position)
				custom_pos = true
				agent.target_position = last_point
				break
			custom_pos = false
		
			last_point = v
			new_path.append(v - global_position)
		
		draw_circle(last_point - global_position, 10, Color.RED)
		draw_polyline(new_path, Color.BLACK, 3)
	
	var color = Color.BLACK
	color.a = 0.2
	
	if is_action(PlayerAction.EXPLODE):
		draw_circle(Vector2(0,0), explode_radius, color)
		
	if is_action(PlayerAction.ATTACK):
		var start_angle = get_angle_to(get_global_mouse_position())
		draw_arc(Vector2(0,0), attack_radius, start_angle, start_angle + attack_angle, 10, color, attack_radius)
		
	if is_action(PlayerAction.ATTACKING):
		var start_angle = attack_area.rotation - (PI / 2)
		draw_arc(Vector2(0,0), attack_radius, start_angle - attack_width, start_angle, 10, Color.WHITE, attack_radius)
		
func _process(delta):
	queue_redraw()
	
	if is_action(PlayerAction.MOVE) or is_action(PlayerAction.DASH):
		
		agent.target_position = get_global_mouse_position()
		agent.is_target_reachable()
	
func _physics_process(delta):
	if not is_action(PlayerAction.MOVING) and not is_action(PlayerAction.DASHING):
		return
	
	if agent.is_navigation_finished():
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = agent.get_next_path_position()
	
	velocity = current_agent_position.direction_to(next_path_position) * get_speed()
	
	move_and_slide()


func _on_attack_area_body_entered(body : Node2D):
	if body.is_in_group("enemy") and is_action(PlayerAction.ATTACKING):
		body.damage(attack_damage)

func heal(value):
	# TODO: Heal sound
	health += value % max_health
	
func damage(value):
	damage_player.play()
	health -= value
	
	if health <= 0:
		kill()
		
func kill():
	queue_free()
	get_tree().paused = true
	
func try_damage_player(body):
	if body.is_in_group("enemy"):
		damage(body.attack_damage)
		
func _on_area_2d_body_entered(body):
	try_damage_player(body)

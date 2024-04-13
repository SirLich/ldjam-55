extends CharacterBody2D
class_name Player

@export var max_health : int =  100
var health

@export var move_distance : float
@export var movement_speed: float = 600.0

@export var explode_radius : float = 50
@export var explode_damage : float = 10

@export var attack_radius : float = 75
@export var attack_angle = PI/2
@export var attack_speed = 0.3
@export var attack_damage : float = 10
var attack_width = 0.0
@export var agent : NavigationAgent2D
@export var action_debug_label : Label
@export var explosion_area : Area2D
@export var explosion_shape : CollisionShape2D
@export var sprite : AnimatedSprite2D

@export var attack_area = Area2D
@export var attack_shape = CollisionShape2D


var action : PlayerAction

enum PlayerAction {
	NONE,
	MOVE,
	MOVING,
	EXPLODE,
	EXPLODING,
	ATTACK,
	ATTACKING
}

func _ready():
	health = max_health
	agent.navigation_finished.connect(on_navigation_finished)
	sprite.play("idle")

func on_navigation_finished():
	set_action(PlayerAction.NONE)
	
func is_action(in_action):
	return in_action == action
	
func set_action(in_action):
	if in_action is PlayerAction:
		action = in_action
	else:
		action = PlayerAction.get(in_action)
	
	action_debug_label.text = PlayerAction.find_key(action)
	
	if action == PlayerAction.MOVING:
		Bus.perform_action.emit(PlayerAction.MOVE)
		agent.target_position = get_global_mouse_position()
		sprite.play("walk")
	else:
		sprite.play("idle")
		
	if action == PlayerAction.EXPLODING:
		Bus.perform_action.emit(PlayerAction.EXPLODE)
		perform_explosion()
		
	if action == PlayerAction.ATTACKING:
		Bus.perform_action.emit(PlayerAction.ATTACK)
		perform_attack()

func perform_attack():
	attack_shape.shape.size.y = attack_radius + 55
	
	var start_angle = get_angle_to(get_global_mouse_position()) + PI/2
	var tween = get_tree().create_tween()
	attack_area.rotation = start_angle
	var attack_anim_speed = attack_speed / 2
	tween.tween_property(attack_area, "rotation", start_angle + attack_angle, attack_speed)
	var anim_tween = get_tree().create_tween()
	anim_tween.tween_property(self, "attack_width", PI/2, attack_anim_speed)
	anim_tween.tween_property(self, "attack_width", 0, attack_anim_speed)
	
	await tween.finished
	
	set_action(PlayerAction.NONE)
	
func perform_explosion():
	var tween = get_tree().create_tween()
	
	explosion_shape.shape.radius = explode_radius
	for body in explosion_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.damage(explode_damage)
		
	await get_tree().create_timer(2).timeout
	set_action(PlayerAction.NONE)
	
func _input(event):
	if event.is_action_released("right_click"):
		set_action(PlayerAction.NONE)
	
	if event.is_action_released("left_click"):
		if is_action(PlayerAction.MOVE):
			set_action(PlayerAction.MOVING)
		if is_action(PlayerAction.ATTACK):
			set_action(PlayerAction.ATTACKING)
		if is_action(PlayerAction.EXPLODE):
			set_action(PlayerAction.EXPLODING)

func _draw():
	if is_action(PlayerAction.MOVE):
		var path = agent.get_current_navigation_path()
		var new_path : PackedVector2Array
		for v in path:
			new_path.append(v - global_position)
		
		draw_polyline(new_path, Color.BLACK, 2)
	
	if is_action(PlayerAction.EXPLODE):
		draw_circle(Vector2(0,0), explode_radius, Color.BLANCHED_ALMOND)
		
	if is_action(PlayerAction.ATTACK):
		var start_angle = get_angle_to(get_global_mouse_position())
		draw_arc(Vector2(0,0), attack_radius, start_angle, start_angle + attack_angle, 10, Color.AQUA, attack_radius)
		
	if is_action(PlayerAction.ATTACKING):
		var start_angle = attack_area.rotation - (PI / 2)
		draw_arc(Vector2(0,0), attack_radius, start_angle - attack_width, start_angle, 10, Color.WHITE, attack_radius)
		
func _process(delta):
	queue_redraw()
	
	if is_action(PlayerAction.MOVE):
		
		agent.target_position = get_global_mouse_position()
		agent.is_target_reachable()
	
func _physics_process(delta):
	if not is_action(PlayerAction.MOVING):
		return
	
	if agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()


func _on_attack_area_body_entered(body : Node2D):
	if body.is_in_group("enemy") and is_action(PlayerAction.ATTACKING):
		body.damage(attack_damage)

func damage(value):
	health -= value
	
	if health <= 0:
		kill()
		
func kill():
	queue_free()
	

func _on_area_2d_body_entered(body):
	if body.is_in_group("enemy"):
		damage(body.attack_damage)

extends CharacterBody2D
class_name Player

@export var move_distance : float
@export var movement_speed: float = 600.0

@export var explode_radius : float = 50
@export var explode_damage : float = 10

@export var attack_radius : float = 75
@export var attack_angle = PI/2
@export var attack_speed = 10


@export var agent : NavigationAgent2D
@export var action_debug_label : Label
@export var explosion_area : Area2D
@export var explosion_shape : CollisionShape2D

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
	
	agent.navigation_finished.connect(on_navigation_finished)
	
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
		agent.target_position = get_global_mouse_position()
	if action == PlayerAction.EXPLODING:
		perform_explosion()

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
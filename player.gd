extends CharacterBody2D
class_name Player

@export var move_distance : float
@export var movement_speed: float = 200.0

@export var explode_radius : float = 50

@export var agent : NavigationAgent2D
@export var action_debug_label : Label


var action : PlayerAction

enum PlayerAction {
	NONE,
	MOVE,
	MOVING,
	EXPLODE,
	EXPLODING
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
	
func _input(event):
	if event.is_action_released("right_click"):
		set_action(PlayerAction.NONE)
		
	if is_action(PlayerAction.MOVE):
		if event.is_action_released("left_click"):
			set_action(PlayerAction.MOVING)

func _draw():
	if is_action(PlayerAction.MOVE):
		var path = agent.get_current_navigation_path()
		var new_path : PackedVector2Array
		for v in path:
			new_path.append(v - global_position)
		
		draw_polyline(new_path, Color.BLACK, 2)
	
	if is_action(PlayerAction.EXPLODE):
		draw_circle(Vector2(0,0), explode_radius, Color.BLANCHED_ALMOND)
		
		
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

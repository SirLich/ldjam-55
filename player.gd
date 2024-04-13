extends CharacterBody2D
class_name Player

@export var move_distance : float
@export var movement_speed: float = 200.0

@export var agent : NavigationAgent2D

var action : PlayerAction

enum PlayerAction {
	NONE,
	MOVE
}

func is_action(in_action):
	return in_action == action
	
func set_action(in_action):
	if in_action is PlayerAction:
		action = in_action
	else:
		action = PlayerAction.get(in_action)
	
func _input(event):
	if event.is_action_released("right_click"):
		set_action(PlayerAction.NONE)
		
	if event.is_action_released("left_click"):
		set_action(PlayerAction.NONE)

func _draw():
	if is_action(PlayerAction.MOVE):
		draw_line(Vector2(0,0), get_local_mouse_position(), Color.BLACK, 3)
	
func _process(delta):
	queue_redraw()
	
	if is_action(PlayerAction.MOVE):
		agent.target_position = get_global_mouse_position()
	
func _physics_process(delta):
	if not is_action(PlayerAction.MOVE):
		return
	
	if agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

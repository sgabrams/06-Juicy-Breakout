extends RigidBody2D

onready var Game = get_node("/root/Game")
onready var Camera = get_node("/root/Game/Camera")
onready var Starting = get_node("/root/Game/Starting")

#sounds
onready var Wav1 = get_node("/root/Game/Wav1")
onready var Wav2 = get_node("/root/Game/Wav2")
onready var Wav3 = get_node("/root/Game/Wav3")

var _decay_rate = 0.8
var _max_offset = 4
var trauma_color = Color(1,1,1,1) 

var _start_size
var _start_position
var _trauma = 0.0
var _rotation = 0
var _rotation_speed = 0.5
var _color = 0.0
var _color_decay = 1
var _normal_color


func _ready():
	contact_monitor = true
	set_max_contacts_reported(4)
	_start_position = $ColorRect.rect_position
	_normal_color = $ColorRect.color

func _process(delta):
	if _trauma > 0:
		_decay_trauma(delta)
		_apply_shake()
	if _color > 0:
		_decay_color(delta)
		_apply_color()
	if _color == 0 and $ColorRect.color != _normal_color:
		$ColorRect.color = _normal_color
		

func _physics_process(delta):
	# Check for collisions
	var bodies = get_colliding_bodies()
	for body in bodies:
		Camera.add_trauma(0.6)
		add_trauma(2.0)
		if body.is_in_group("Tiles"):
			Game.change_score(body.points)
			add_color(1.0)
			Wav1.playing = true
			body.kill()
		if body.name == "Paddle":
			body.find_node("Confetti").emitting = true
			Wav2.playing = true
			var tile_rows = get_tree().get_nodes_in_group("Tile Row")
			for tile in tile_rows:
				tile.add_trauma(0.5)
		if body.name == "Wall":
			Wav1.playing = true
	
	rotate(_rotation)
	_rotation += (_rotation_speed * linear_velocity.normalized().x)

	
	if position.y > get_viewport().size.y:
		Game.change_lives(-1)
		Starting.startCountdown(3)
		queue_free()




func add_color(amount):
	_color += amount
	
func _apply_color():
	var a = min(1,_color)
	$ColorRect.color = _normal_color.linear_interpolate(trauma_color, a)

func _decay_color(delta):
	var change = _color_decay * delta
	_color = max(_color - change, 0)

func add_trauma(amount):
	_trauma = min(_trauma + amount, 1)
	
func _decay_trauma(delta):
	var change = _decay_rate * delta
	_trauma = max(_trauma - change, 0)

func _apply_shake():
	var shake = _trauma + _trauma
	var o_x = _max_offset + shake + _get_neg_or_pos_scalar()
	var o_y = _max_offset + shake + _get_neg_or_pos_scalar()
	$ColorRect.rect_position = _start_position + Vector2(o_x, o_y)

func _get_neg_or_pos_scalar():
	return rand_range(-1.0,1.0)

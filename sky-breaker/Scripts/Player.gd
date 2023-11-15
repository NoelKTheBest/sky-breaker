extends KinematicBody2D

export var ACCEL = 10
export var DECEL = 25
export var gravity = 400
export var SPEED = 200.0
export var JUMP_VELOCITY = -300.0

var velocity = Vector2(0, 0)
var cling_to_wall
var cling_dir
var cling_duration
var timer_started
var wall_jump

# Called when the node enters the scene tree for the first time.
func _ready():
	#$AnimatedSprite.play("Idle")
	cling_to_wall = false
	cling_duration = 5.0
	cling_dir = 0
	timer_started = false

func _process(delta):
	if velocity.x == 0 and is_on_floor():
		$AnimatedSprite.play("Idle")
	elif velocity.x != 0 and is_on_floor():
		$AnimatedSprite.play("Run")
	else:
		if velocity.y < -5:
			$AnimatedSprite.play("Jump")
		
		if (velocity.y > -5 and velocity.y < 5):
			$AnimatedSprite.play("Airborne")
		
		if velocity.y > 5:
			$AnimatedSprite.play("Fall")
	
	if is_on_wall() and not is_on_floor():
		$AnimatedSprite.play("Wall Cling")
	
	if wall_jump:
		$AnimatedSprite.play("Jump")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if is_on_wall(): velocity.y = clamp(velocity.y, JUMP_VELOCITY, 100)
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.	
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x += direction * ACCEL + velocity.x * delta
		velocity.x = clamp(velocity.x, -1 * SPEED, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
#		if not $WallJumpTimer.is_stopped():
	
#	print(velocity.x)
	
	if direction < 0 or velocity.x < 0:
		$AnimatedSprite.flip_h = true
	elif direction > 0 or velocity.x > 0:
		$AnimatedSprite.flip_h = false
	
	if is_on_wall():
		if Input.is_action_just_pressed("jump"):
#			velocity.y = JUMP_VELOCITY
			var facing_dir = 0
			if $AnimatedSprite.flip_h == false: facing_dir = 1
			else: facing_dir = -1
#			print("x before: " + str(velocity.x))
			velocity = Vector2(facing_dir * (SPEED / 2), JUMP_VELOCITY)
#			print("x after: " + str(velocity.x))
#			$WallJumpTimer.start()
	
	move_and_slide(velocity, Vector2(0, -1))


func _on_WallCingTimer_timeout():
	cling_to_wall = false
	# timer_started = false
	#print("timer stopped")


func _on_WallJumpTimer_timeout():
	wall_jump = false

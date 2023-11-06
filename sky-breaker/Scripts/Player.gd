extends KinematicBody2D

var gravity = 400
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
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
		if (velocity.y > -5 and velocity.y < 5) and !cling_to_wall:
			$AnimatedSprite.play("Airborne")
		
		if velocity.y > 5:
			$AnimatedSprite.play("Fall")
	
	if cling_to_wall and !timer_started:
		$WallClingTimer.start()
		timer_started = true
	
	if wall_jump:
		$AnimatedSprite.play("Jump")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_floor() and timer_started:
		timer_started = false
		if cling_to_wall: cling_to_wall == false
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite.play("Jump")
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction = Input.get_axis("move_left", "move_right")
	
	if !wall_jump:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction < 0 or velocity.x < 0:
		$AnimatedSprite.flip_h = true
	elif direction > 0 or velocity.x > 0:
		$AnimatedSprite.flip_h = false
	
	if is_on_wall():
		if direction != 0 and direction != cling_dir and !cling_to_wall and !timer_started and !wall_jump:
			velocity = Vector2.ZERO
			cling_dir = direction
			cling_to_wall = true
			#print("cling to wall")
			$AnimatedSprite.play("Wall Cling")
		elif direction == cling_dir and cling_to_wall:
			velocity = Vector2.ZERO
			#print("hang onto wall")
			
			if Input.is_action_just_pressed("jump"):
				velocity = Vector2(-direction * SPEED, JUMP_VELOCITY)
				wall_jump = true
				$WallJumpTimer.start()
		elif direction != cling_dir and cling_to_wall:
			#print("push off wall")
			pass
		elif direction == cling_dir and !cling_to_wall:
			#print("timeout")
			cling_dir = 0
			pass
	
	move_and_slide(velocity, Vector2(0, -1))


func _on_WallCingTimer_timeout():
	cling_to_wall = false
	# timer_started = false
	#print("timer stopped")


func _on_WallJumpTimer_timeout():
	wall_jump = false

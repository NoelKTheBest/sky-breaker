extends KinematicBody2D

var gravity = 400
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
var velocity = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	#$AnimatedSprite.play("Idle")
	pass

func _process(delta):
	if velocity.x == 0 and is_on_floor():
		$AnimatedSprite.play("Idle")
	elif velocity.x != 0 and is_on_floor():
		$AnimatedSprite.play("Run")
	else:
		if (velocity.y > -1 and velocity.y < 1):
			$AnimatedSprite.play("Airborne") 
		
		if velocity.y > 0:
			$AnimatedSprite.play("Fall")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite.play("Jump")
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction < 0:
		$AnimatedSprite.flip_h = true
	elif direction > 0:
		$AnimatedSprite.flip_h = false
	
	move_and_slide(velocity, Vector2(0, -1))

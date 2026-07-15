extends CharacterBody2D
class_name Player

#region State Machinery 1: The Variables
@export_category('State Machinery')
@export var stateMachine:PlayerStateMachine
var curState:PlayerStatePattern = null
var prevState:PlayerStatePattern = null
#endregion

#region Technical
@export_category('Technical')
@export var plySprite:AnimatedSprite2D

@export var defaultColl:CollisionShape2D
@export var rollingColl:CollisionShape2D
@export var currentColl:String = "default"
#endregion

#region Stats
## now beware! we are using Subpixels for this
@export_category('Stats')
@export var FRICTION:int = 12
@export var ROLL_FRICTION:int = 6
@export var ACCEL:int = 12
@export var AIR_ACCEL:int = 24
@export var DECEL:int = 128
@export var ROLL_DECEL:int = 32
@export var TOP_SPEED:int = 1536
@export var JUMP_FORCE:int = 1664
@export var GRAVITY:int = 56
#endregion

#region Uhhhhhhhhhhhhh lol
var motion:Vector2 = Vector2.ZERO
var practicalAngle:float = 0
var jumping:bool = false
var holdingJump:bool = false
var skidding:bool = false

var controlLock:int = 0
#endregion

func _ready() -> void:
	for state in stateMachine.get_children():
		state.machine = stateMachine
		state.player = self
		state.stateName = state.name
	curState = stateMachine.stateIndex['Floor']
	prevState = stateMachine.stateIndex['Default']
	pass

#region Here be Physix
var cameFromAir:bool = false

func handlePhysics(controllable = true, grav = GRAVITY):
	var canControl = controllable and controlLock <= 0
	
	var accelCool = Maths.desubpixel(ACCEL)
	var decelCool = Maths.desubpixel(DECEL)
	
	if not is_on_floor():
		accelCool = Maths.desubpixel(AIR_ACCEL)
		decelCool = Maths.desubpixel(AIR_ACCEL)
	
	if canControl:
		# manually transcribed from sonic retro's sonic physics guide
		if Input.is_action_pressed("ui_left"):
			if Input.is_action_just_pressed("ui_left"):
				skidding = (motion.x > 4)
			if (motion.x > 0):
				motion.x -= decelCool
				if (motion.x <= 0):
					motion.x = -0.5 # deceleration quirk
			elif (motion.x > Maths.desubpixel(-TOP_SPEED)):
				skidding = false
				motion.x -= accelCool
				if (motion.x <= Maths.desubpixel(-TOP_SPEED)):
					motion.x = Maths.desubpixel(-TOP_SPEED)
		elif Input.is_action_pressed("ui_right"):
			if Input.is_action_just_pressed("ui_right"):
				skidding = (motion.x < -4)
			if (motion.x < 0):
				motion.x += decelCool
				if (motion.x >= 0):
					motion.x = 0.5 # deceleration quirk
			elif (motion.x < Maths.desubpixel(TOP_SPEED)):
				skidding = false
				motion.x += accelCool
				if (motion.x >= Maths.desubpixel(TOP_SPEED)):
					motion.x = Maths.desubpixel(TOP_SPEED)
	
	if is_on_floor():
		# Go from The Air into The Slope
		if cameFromAir:
			if jumping:
				jumping = false
				holdingJump = false
				onLand()
			motion = motion.rotated(-(get_floor_normal().angle() + PI/2))
			cameFromAir = false
		up_direction = get_floor_normal()
		practicalAngle = get_floor_normal().angle() + PI/2
		motion.x += Maths.desubpixel(FRICTION) * get_floor_normal().x * 2
		
		# SLIP LOGIC...
		var angleToCompare = Maths.angle_fixer_deg(rad_to_deg(up_direction.angle()) + 90) 
		# print(angleToCompare)
		if Maths.angle_fixer_deg(angleToCompare) > 46 \
		and Maths.angle_fixer_deg(angleToCompare) < 315:
			if abs(motion.x) < Maths.desubpixel(128, 2):
				controlLock = 15
				motion.y = 0
				up_direction = Vector2(0.0, -1.0)
		
		if (not Input.is_action_pressed("ui_right") \
		and not Input.is_action_pressed("ui_left")) \
		or not canControl:
			if abs(motion.x) < 0.001:
				skidding = false
			motion.x -= min(abs(motion.x), Maths.desubpixel(FRICTION)) * sign(motion.x) # decelerate
		
		# Little additional thing just so that physics dont suck shit
		if motion.y > 0:
			motion.y = 4
	else:
		# Get Launched by A Slope !!!
		if up_direction != Vector2(0.0, -1.0):
			var prevmotion := Vector2(
				motion.x * -up_direction.y - motion.y * up_direction.x,
				motion.y * -up_direction.y + motion.x * up_direction.x,
				)
			up_direction = Vector2(0.0, -1.0)
			motion = prevmotion
		motion.y += Maths.desubpixel(grav)
		cameFromAir = true
	
	handleJump(canControl)
	# Sonic the Rotationhog
	var deg90 = (PI/2)
	var deg45 = (PI/4)
	velocity = motion.rotated(up_direction.angle() + deg90) * 60
	rotation = round((up_direction.angle() + deg90) / deg90) * -deg90
	# and for my next trick i will indent an expression
	plySprite.rotation = (
							round(
								(up_direction.angle() + deg90) / deg45
							) 
							* deg45
						) - rotation
	
	if is_on_wall():
		motion.x = clampf(motion.x, -1, 1)
	move_and_slide()

func handleJump(controllable = true):
	# jump!
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up") and controllable:
			# print('pressed')
			jumping = true
			holdingJump = true
			motion.y = Maths.desubpixel(-JUMP_FORCE)
			onJump()
	else:
		if Input.is_action_just_released("ui_up") and holdingJump:
			# print('lifted')
			holdingJump = false
			if motion.y < -4:
				motion.y = -4

func debugFuckery():
	if Input.is_action_just_pressed("ui_down"):
		toggleCurrentCollision()
#endregion

func _physics_process(delta: float) -> void:
	#control lock
	if controlLock > 0:
		controlLock -= 1
		
	handlePhysics()
	debugFuckery()
	curState.update()

#region Utilitary functions
func toggleCurrentCollision():
	match currentColl:
		"rolling":
			setCurrentCollision("default")
		_:
			setCurrentCollision("rolling")

func setCurrentCollision(which:String):
	# Ideally both of em should be on the center
	rollingColl.disabled = (which != "rolling")
	
	var defSize = defaultColl.shape.get_rect().size.y
	var rollSize = rollingColl.shape.get_rect().size.y
	var theDifference = defSize / 2 - rollSize / 2
	match which:
		"rolling":
			if currentColl != "rolling":
				position += Vector2(0, theDifference).rotated(up_direction.angle() + (PI/2))
		_:
			if currentColl == "rolling":
				position += Vector2(0, -theDifference).rotated(up_direction.angle() + (PI/2))
	
	defaultColl.disabled = (which == "rolling")
	
	currentColl = which
#endregion

#region Scripting assist
func onJump():
	pass

func onLand():
	pass
#endregion

#region State Machinery 2: The Functions
func changeState(new_state:Variant):
	if new_state is PlayerStatePattern:
		changeStateByPattern(new_state)
	else:
		changeStateByName(str(new_state))

func changeStateByPattern(new_state:PlayerStatePattern):
	if new_state != null:
		prevState = curState
		curState = new_state
		prevState.exitState()
		curState.enterState()

func changeStateByName(new_state:String):
	changeStateByPattern(stateMachine.stateIndex[new_state])
#endregion

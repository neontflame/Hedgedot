extends PlayerStatePattern

func enterState():
	pass

func update():
	animate()
	keyWhatevers()
	
	if not player.is_on_floor():
		player.changeState("Air")

func keyWhatevers():
	if player.skidding:
		player.plySprite.flip_h = (player.motion.x < 0)
	else:
		if Input.is_action_pressed("ui_left"):
			player.plySprite.flip_h = true
		if Input.is_action_pressed("ui_right"):
			player.plySprite.flip_h = false

func animate():
	var animSpeed = (Maths.subpixel_pixel(abs(player.motion.x))[1]) / 3
	if player.is_on_floor():
		if abs(player.motion.x) > 0:
			if player.skidding:
				player.plySprite.play("skid")
			else:
				if abs(player.motion.x) >= Maths.desubpixel(0, 6):
					player.plySprite.play("run", animSpeed)
				else:
					player.plySprite.play("walk", animSpeed)
		else:
			player.plySprite.play("idle")

func exitState():
	pass

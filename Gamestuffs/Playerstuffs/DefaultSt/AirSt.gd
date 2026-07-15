extends PlayerStatePattern

func enterState():
	if player.jumping:
		player.plySprite.play("spin", 
		max(1, (Maths.subpixel_pixel(abs(player.motion.x))[1]) / 3)
		)

func update():
	if player.is_on_floor():
		player.changeState("Floor")

func exitState():
	pass


extends Node2D

var ball := Vector2(576, 324)
var ball_velocity := Vector2(360, 220)

var left_y := 324.0
var right_y := 324.0

var left_score := 0
var right_score := 0

const PADDLE_W := 18.0
const PADDLE_H := 100.0
const BALL_R := 10.0
const PADDLE_SPEED := 450.0
const BALL_SPEED := 360.0

func _ready() -> void:
	# Start background music
	$MusicPlayer.play()

func _process(delta: float) -> void:
	var screen = get_viewport_rect().size

	# Left paddle: W and S
	if Input.is_key_pressed(KEY_W):
		left_y -= PADDLE_SPEED * delta
	if Input.is_key_pressed(KEY_S):
		left_y += PADDLE_SPEED * delta

	# Right paddle: simple computer opponent
	if ball.y > right_y + 10:
		right_y += PADDLE_SPEED * delta
	elif ball.y < right_y - 10:
		right_y -= PADDLE_SPEED * delta

	left_y = clampf(left_y, PADDLE_H / 2, screen.y - PADDLE_H / 2)
	right_y = clampf(right_y, PADDLE_H / 2, screen.y - PADDLE_H / 2)

	# Move ball
	ball += ball_velocity * delta

	# Bounce off top and bottom
	if ball.y < BALL_R or ball.y > screen.y - BALL_R:
		ball_velocity.y *= -1
		$HitPlayer.play()

	# Bounce off left paddle
	if ball_velocity.x < 0:
		if ball.x - BALL_R <= 49 and ball.x > 25:
			if abs(ball.y - left_y) < PADDLE_H / 2 + BALL_R:
				$HitPlayer.play()
				ball_velocity.x = BALL_SPEED
				ball_velocity.y += (ball.y - left_y) * 3

	# Bounce off right paddle
	if ball_velocity.x > 0:
		if ball.x + BALL_R >= screen.x - 49 and ball.x < screen.x - 25:
			if abs(ball.y - right_y) < PADDLE_H / 2 + BALL_R:
				$HitPlayer.play()
				ball_velocity.x = -BALL_SPEED
				ball_velocity.y += (ball.y - right_y) * 3

	# Scoring
	if ball.x < 0:
		right_score += 1
		reset_ball(1)

	if ball.x > screen.x:
		left_score += 1
		reset_ball(-1)

	queue_redraw()

func reset_ball(direction: int) -> void:
	ball = get_viewport_rect().size / 2
	ball_velocity = Vector2(direction * BALL_SPEED, 220)

func _draw() -> void:
	var screen = get_viewport_rect().size

	# Dark background
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#080b1c"))

	# Center line
	for y in range(0, int(screen.y), 30):
		draw_rect(
			Rect2(Vector2(screen.x / 2 - 2, y), Vector2(4, 15)),
			Color("#343b60")
		)

	# Neon paddles
	draw_rect(
		Rect2(Vector2(40, left_y - PADDLE_H / 2),
		Vector2(PADDLE_W, PADDLE_H)),
		Color("#00f5ff")
	)

	draw_rect(
		Rect2(Vector2(screen.x - 58, right_y - PADDLE_H / 2),
		Vector2(PADDLE_W, PADDLE_H)),
		Color("#ff36d1")
	)

	# Ball
	draw_circle(ball, BALL_R, Color.WHITE)

	# Score
	draw_string(
		ThemeDB.fallback_font,
		Vector2(screen.x * 0.35, 65),
		str(left_score),
		HORIZONTAL_ALIGNMENT_CENTER, -1, 42, Color("#00f5ff")
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(screen.x * 0.65, 65),
		str(right_score),
		HORIZONTAL_ALIGNMENT_CENTER, -1, 42, Color("#ff36d1")
	)

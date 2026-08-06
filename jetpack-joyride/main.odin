package main

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

SCALING :: 5
GRAVITY :: 500
JUMP_VELOCITY :: -300
FRAME1 :: rl.Rectangle{0, 0, 16, 16}
FRAME2 :: rl.Rectangle{16, 0, 16, 16}
FRAME3 :: rl.Rectangle{32, 0, 16, 16}
obstacle_velocity: f32 = -300

Game :: enum {
	menu,
	gameplay,
	deathscreen,
}

Player_State :: enum {
	on_air,
	on_ground,
}
Animation_State :: enum {
	frame_1,
	frame_2,
	frame_3,
}

Player :: struct {
	rectangle:       rl.Rectangle,
	velocity_y:      f32,
	color:           rl.Color,
	texture:         rl.Texture2D,
	state:           Player_State,
	animation_timer: Timer,
	animation_frame: Animation_State,
}

Obstacle :: struct {
	rectangle: rl.Rectangle,
	color:     rl.Color,
	texture:   rl.Texture2D,
}

Button :: struct {
	rectangle:  rl.Rectangle,
	color:      rl.Color,
	texture:    rl.Texture2D,
	function:   proc(),
	is_pressed: bool,
}

Timer :: struct {
	start_time:   f32,
	current_time: f32,
	passed_time:  f32,
	max_time:     f32,
}

//Globals
player: Player
obstacle_list: [dynamic]Obstacle
obstacle_timer: Timer
score_timer: Timer
gamestate: Game
button_list: [dynamic]Button
score: f32 = 0


main :: proc() {

	rl.InitWindow(720, 480, "Jetpack Joyride")
	gamestate = .menu

	play_button_texture := rl.LoadTexture("./sprites/play-button.png")
	player_texture := rl.LoadTexture("./sprites/player.png")
	obstacle_texture := rl.LoadTexture("./sprites/obstacle.png")

	player = {
		rectangle = {0, 0, 16 * SCALING, 16 * SCALING},
		texture = player_texture,
		color = rl.WHITE,
		state = .on_air,
		animation_timer = {start_time = f32(rl.GetTime()), max_time = 0.1},
	}
	create_buttons(&button_list, play_button_texture)

	for !rl.WindowShouldClose() {

		switch (gamestate) {
		case .menu:
			handle_menu()
		case .gameplay:
			handle_gameplay(obstacle_texture)
		case .deathscreen:
			handle_deathscreen()
		}
	}
}

handle_menu :: proc() {

	//Update
	handle_buttons()
	//Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	draw_buttons()
	rl.EndDrawing()
}

create_buttons :: proc(bl: ^[dynamic]Button, play_button_texture: rl.Texture2D) {

	play_button: Button = {
		rectangle  = {
			//Formula to make it on middle
			360 - (72 * SCALING / 2),
			240 - (32 * SCALING / 2),
			72 * SCALING,
			32 * SCALING,
		},
		color      = rl.WHITE,
		is_pressed = false,
		texture    = play_button_texture,
	}
	append(bl, play_button)
}

handle_buttons :: proc() {

	mouse_pos := rl.GetMousePosition()
	for &but in button_list {

		if rl.CheckCollisionPointRec(mouse_pos, but.rectangle) && rl.IsMouseButtonDown(.LEFT) {
			but.is_pressed = true
		}
		if (rl.IsMouseButtonReleased(.LEFT) && but.is_pressed == true) {
			gamestate = .gameplay
			but.is_pressed = false
			init_timers()
		}

	}
}

draw_buttons :: proc() {

	for button in button_list {
		rl.DrawTexturePro(
			button.texture,
			{0, 0, 72, 32},
			button.rectangle,
			{0, 0},
			0,
			button.color,
		)
	}
}

handle_gameplay :: proc(obstacle_texture: rl.Texture2D) {

	//Update
	dt := rl.GetFrameTime()

	handle_timers()

	score = obstacle_velocity * score_timer.passed_time * (-0.001)

	//Input
	if rl.IsKeyDown(.SPACE) || rl.IsMouseButtonDown(.LEFT) {
		player.velocity_y = JUMP_VELOCITY
	}

	//Player
	handle_player(dt)

	//Obstacles
	if (len(obstacle_list) == 0) {
		spawn_obstacle(obstacle_texture)
	}
	move_obstacles(dt)

	//Collision
	for o in obstacle_list {
		if rl.CheckCollisionRecs(player.rectangle, o.rectangle) {
			for &but in button_list {
				but.is_pressed = false
			}
			player.rectangle.x = 0
			player.rectangle.y = 0
			clear(&obstacle_list)
			gamestate = .menu
		}
	}
	cstr_score := rl.TextFormat("%.0f KM", score)

	//Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	rl.DrawText(cstr_score, 0, 0, 5 * SCALING, rl.BLACK)
	draw_player()
	draw_obstacles()
	rl.EndDrawing()

}

spawn_obstacle :: proc(obstacle_texture: rl.Texture2D) {

	rand := rand.float32_range(0, 480 - (16 * SCALING))
	temp_obstacle: Obstacle = {
		rectangle = {720, rand, 16 * SCALING, 16 * SCALING},
		color     = rl.RED,
		texture   = obstacle_texture,
	}

	append(&obstacle_list, temp_obstacle)
}

draw_obstacles :: proc() {
	for obstacle in obstacle_list {
		rl.DrawTexturePro(
			obstacle.texture,
			{0, 0, 16, 16},
			obstacle.rectangle,
			{0, 0},
			0,
			obstacle.color,
		)
	}
}

move_obstacles :: proc(dt: f32) {

	for &o, i in obstacle_list {
		o.rectangle.x += obstacle_velocity * dt
		if (o.rectangle.x < -(16 * SCALING)) {
			ordered_remove(&obstacle_list, i)

		}
	}
}

handle_player :: proc(dt: f32) {


	//State
	if (player.rectangle.y < (480 - (16 * SCALING))) {
		player.state = .on_air
	} else {
		player.state = .on_ground
	}

	//Animation timer
	player.animation_timer.current_time = f32(rl.GetTime())
	player.animation_timer.passed_time =
		player.animation_timer.current_time - player.animation_timer.start_time
	if (player.animation_timer.passed_time >= player.animation_timer.max_time) {
		player.animation_timer.start_time = f32(rl.GetTime())
		player.animation_timer.current_time = f32(rl.GetTime())
		player.animation_timer.passed_time = 0
		if (player.animation_frame == .frame_2) {
			player.animation_frame = .frame_3
		} else if (player.animation_frame == .frame_3) {
			player.animation_frame = .frame_2
		}
	}

	//Movement
	switch player.state {
	case .on_air:
		player.rectangle.y += player.velocity_y * dt + 0.5 * GRAVITY * dt * dt
		player.velocity_y += GRAVITY * dt
		if (player.rectangle.y < 0) {
			player.rectangle.y = 0
		}
	case .on_ground:
		player.rectangle.y += player.velocity_y * dt
		if (player.rectangle.y > (480 - (16 * SCALING))) {
			player.rectangle.y = 480 - (16 * SCALING)
		}
	}


}

draw_player :: proc() {

	animation_frame: rl.Rectangle

	if (player.state == .on_air) {
		player.animation_frame = .frame_1
	}
	if (player.state == .on_ground && player.animation_frame == .frame_1) {
		player.animation_frame = .frame_2
	}


	switch player.animation_frame {
	case .frame_1:
		animation_frame = FRAME1
	case .frame_2:
		animation_frame = FRAME2
	case .frame_3:
		animation_frame = FRAME3
	}

	rl.DrawTexturePro(player.texture, animation_frame, player.rectangle, {0, 0}, 0, player.color)
}

init_timers :: proc() {
	score_timer = {
		start_time   = f32(rl.GetTime()),
		current_time = f32(rl.GetTime()),
		passed_time  = 0,
	}
	obstacle_timer = {
		start_time   = f32(rl.GetTime()),
		current_time = f32(rl.GetTime()),
		passed_time  = 0,
		max_time     = 5,
	}
}

handle_timers :: proc() {

	score_timer.current_time = f32(rl.GetTime())
	score_timer.passed_time = score_timer.current_time - score_timer.start_time

	obstacle_timer.current_time = f32(rl.GetTime())
	obstacle_timer.passed_time = obstacle_timer.current_time - obstacle_timer.start_time
	if (obstacle_timer.passed_time >= obstacle_timer.max_time) {
		obstacle_timer.start_time = f32(rl.GetTime())
		obstacle_timer.current_time = f32(rl.GetTime())
		obstacle_timer.passed_time = 0
	}
}

handle_deathscreen :: proc() {

}

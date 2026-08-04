package main

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

SCALING :: 5
GRAVITY :: 500
JUMP_VELOCITY :: -300
FRAME1 :: rl.Rectangle{0, 0, 16, 16}
FRAME2 :: rl.Rectangle{16, 0, 16, 16}
obstacle_velocity := 100

Game :: enum {
	menu,
	gameplay,
	deathscreen,
}

Player_State :: enum {
	on_air,
	on_ground,
}

Player :: struct {
	rectangle:  rl.Rectangle,
	velocity_y: f32,
	color:      rl.Color,
	texture:    rl.Texture2D,
	state:      Player_State,
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
	start_time:   f64,
	current_time: f64,
	passed_time:  f64,
	max_time:     f64,
}

//Globals
player: Player
obstacle_list: [dynamic]Obstacle
obstacle_timer: Timer

main :: proc() {

	rl.InitWindow(720, 480, "Jetpack Joyride")
	gamestate: Game = .gameplay

	play_button_texture := rl.LoadTexture("./sprites/play-button.png")
	player_texture := rl.LoadTexture("./sprites/player.png")
	obstacle_texture := rl.LoadTexture("./sprites/obstacle.png")

	player = {
		rectangle = {0, 0, 16 * SCALING, 16 * SCALING},
		texture   = player_texture,
		color     = rl.WHITE,
		state     = .on_air,
	}
	button_list: [dynamic]Button
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

	//Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	rl.EndDrawing()
}

create_buttons :: proc(bl: ^[dynamic]Button, play_button_texture: rl.Texture2D) {

	play_button: Button = {
		rectangle  = {},
		color      = rl.WHITE,
		is_pressed = false,
	}
	append(bl, play_button)
}

handle_gameplay :: proc(obstacle_texture: rl.Texture2D) {

	//Update
	dt := rl.GetFrameTime()

	//Input
	if rl.IsKeyDown(.SPACE) {
		player.velocity_y = JUMP_VELOCITY
	}

	//Player
	handle_player(dt)

	//Obstacles
	if (len(obstacle_list) == 0) {
		fmt.print("Reached")
		spawn_obstacle(obstacle_texture)
	}

	//Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	draw_player()
	draw_obstacles()
	rl.EndDrawing()

}

spawn_obstacle :: proc(obstacle_texture: rl.Texture2D) {

	rand := rand.int31_max(600 - (16 * SCALING))
	temp_obstacle: Obstacle = {
		rectangle = {0, 0, 16 * SCALING, 16 * SCALING},
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

handle_player :: proc(dt: f32) {
	if (player.rectangle.y < (480 - (16 * SCALING))) {
		player.state = .on_air
	} else {
		player.state = .on_ground
	}

	switch player.state {
	case .on_air:
		player.rectangle.y += player.velocity_y * dt + 0.5 * GRAVITY * dt * dt
		player.velocity_y += GRAVITY * dt
	case .on_ground:
		player.rectangle.y += player.velocity_y * dt
		if (player.rectangle.y > (480 - (16 * SCALING))) {
			player.rectangle.y = 480 - (16 * SCALING)
		}
	}


}

draw_player :: proc() {

	if (player.state == .on_air) {
		rl.DrawTexturePro(player.texture, FRAME1, player.rectangle, {0, 0}, 0, player.color)
	} else {

		rl.DrawTexturePro(player.texture, FRAME2, player.rectangle, {0, 0}, 0, player.color)
	}
}

init_timer :: proc() {
	obstacle_timer = {
		start_time   = rl.GetTime(),
		current_time = rl.GetTime(),
		passed_time  = 0,
		max_time     = 5,
	}
}

handle_timer :: proc() {
	obstacle_timer.current_time = rl.GetTime()
	obstacle_timer.passed_time = obstacle_timer.current_time - obstacle_timer.start_time
	if (obstacle_timer.passed_time >= obstacle_timer.max_time) {
		obstacle_timer.start_time = rl.GetTime()
		obstacle_timer.current_time = rl.GetTime()
		obstacle_timer.passed_time = 0
	}
}

handle_deathscreen :: proc() {

}

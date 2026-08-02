package main

import rl "vendor:raylib"

SCALING :: 6
GRAVITY :: 500
JUMP_VELOCITY :: -500

Game :: enum {
	menu,
	gameplay,
	deathscreen,
}

Player :: struct {
	rectangle: rl.Rectangle,
	velocity:  f32,
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

main :: proc() {

	rl.InitWindow(900, 600, "Jetpack Joyride")
	gamestate: Game = .gameplay

	play_button_texture := rl.LoadTexture("./sprites/play-button.png")
	player_texture := rl.LoadTexture("./sprites/player.png")

	player: Player = {
		rectangle = {0, 0, 16 * SCALING, 16 * SCALING},
		texture   = player_texture,
		color     = rl.WHITE,
	}
	button_list: [dynamic]Button
	create_buttons(&button_list, play_button_texture)

	for !rl.WindowShouldClose() {

		switch (gamestate) {
		case .menu:
			handle_menu()
		case .gameplay:
			handle_gameplay(&player)
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
handle_gameplay :: proc(player: ^Player) {

	//Update
	dt := rl.GetFrameTime()

	//Input
	if rl.IsKeyDown(.SPACE) {
		player.velocity = JUMP_VELOCITY
	}

	//Player
	player.rectangle.y += player.velocity * dt + 0.5 * GRAVITY * dt * dt
	player.velocity += GRAVITY * dt

	//Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	rl.DrawTexturePro(player.texture, {0, 0, 16, 16}, player.rectangle, {0, 0}, 0, player.color)
	rl.EndDrawing()

}
handle_deathscreen :: proc() {

}

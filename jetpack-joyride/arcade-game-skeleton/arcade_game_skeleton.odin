package skeleton

import rl "vendor:raylib"

Button :: struct {
	rectangle:  rl.Rectangle,
	color:      rl.Color,
	texture:    rl.Texture2D,
	function:   proc(),
	is_pressed: bool,
}

button_list: [dynamic]Button

init_game_skeleton :: proc(SCALING: f32) {

	play_button_texture := rl.LoadTexture("./sprites/play-button.png")
	create_buttons(play_button_texture, SCALING)
}

handle_menu :: proc() -> bool {

	transition_flag: bool = false
	//Update
	transition_flag = handle_buttons()
	//Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	draw_buttons()
	rl.EndDrawing()

	return transition_flag
}

create_buttons :: proc(play_button_texture: rl.Texture2D, SCALING: f32) {

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
	append(&button_list, play_button)
}

handle_buttons :: proc() -> bool {
	transition_flag: bool = false

	mouse_pos := rl.GetMousePosition()
	for &but in button_list {

		if rl.CheckCollisionPointRec(mouse_pos, but.rectangle) && rl.IsMouseButtonDown(.LEFT) {
			but.is_pressed = true
		}
		if (rl.IsMouseButtonReleased(.LEFT) && but.is_pressed == true) {
			transition_flag = true
			but.is_pressed = false
		}

	}

	return transition_flag
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

handle_deathscreen :: proc(score: f32, h_score: f32) -> bool {

	transition_flag: bool = false
	cstr_score := rl.TextFormat("%.0f KM", score)
	cstr_h_score := rl.TextFormat("Best Score: %.0f KM", h_score)

	if (rl.IsKeyReleased(.SPACE)) do transition_flag = true

	//Draw
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	rl.DrawText(cstr_score, 40, rl.GetScreenHeight() / 2, 40, rl.BLACK)
	rl.DrawText(cstr_h_score, 40, rl.GetScreenHeight() / 2 + 40, 40, rl.BLACK)
	rl.DrawText(
		"Press Space to go to the menu...",
		40,
		rl.GetScreenHeight() / 2 + 80,
		40,
		rl.BLACK,
	)

	rl.EndDrawing()

	return transition_flag
}

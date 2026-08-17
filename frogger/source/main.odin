package main

import gs "arcade-game-skeleton"
import rl "vendor:raylib"

GameState :: enum {
	title,
	gameplay,
	death,
}

Obstacle :: struct {
	rectangle: rl.Rectangle,
	velocity:  f32,
	direction: f32,
	texture:   rl.Texture2D,
	color:     rl.Color,
}

score: f32 = 0
h_score: f32 = 0

main :: proc() {
	//Init
	rl.InitWindow(720, 480, "Frogger")

	rl.SetTargetFPS(60)

	gamestate: GameState = .title

	gs.init_game_skeleton(5)

	//Game Loop
	for !rl.WindowShouldClose() {

		switch gamestate {
		case .title:
			gs.handle_menu()
		case .gameplay:
			handle_gameplay_screen()
		case .death:
			gs.handle_deathscreen(score, h_score)
		}
	}
}


handle_gameplay_screen :: proc() {

}

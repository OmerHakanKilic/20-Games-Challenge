package main

import gs "arcade-game-skeleton"
import "core:c"
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

run: bool
score: f32 = 0
h_score: f32 = 0
gamestate: GameState
init :: proc() {
	run = true
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})

	//Init
	rl.InitWindow(720, 480, "Frogger")

	rl.SetTargetFPS(60)

	gamestate = .title

	gs.init_game_skeleton(5)


}

update :: proc() {
	switch gamestate {
	case .title:
		gs.handle_menu()
	case .gameplay:
		handle_gameplay_screen()
	case .death:
		gs.handle_deathscreen(score, h_score)
	}

}

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(c.int(w), c.int(h))
}

shutdown :: proc() {
	rl.CloseWindow()
}

should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		if rl.WindowShouldClose() do run = false
	}
	return run
}

handle_gameplay_screen :: proc() {

}

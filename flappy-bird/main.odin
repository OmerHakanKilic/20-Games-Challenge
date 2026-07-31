package main
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:os"
import "core:strconv"
import rl "vendor:raylib"

GRAVITY :: 200
JUMP_VELOCITY :: -200
SCALE :: 6
pipe_velocity: f32
score: i64 = 0
high_score: i64 = 0

Game :: enum {
	mainmenu,
	gameplay,
	death,
}

Timer :: struct {
	start_time:   f64,
	current_time: f64,
	passed_time:  f64,
	max_time:     f64,
}
Player :: struct {
	rectangle: rl.Rectangle,
	velocity:  f32,
	color:     rl.Color,
	texture:   rl.Texture2D,
}
Pipe :: struct {
	rectangle: rl.Rectangle,
	color:     rl.Color,
	is_scored: bool,
	texture:   rl.Texture2D,
}

main :: proc() {
	rl.InitWindow(900, 600, "Flappy Bird")
	defer rl.CloseWindow()

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	jump_sfx: rl.Sound = rl.LoadSound("./sfx/Pickup_Gold_00.wav")
	death_sfx: rl.Sound = rl.LoadSound("./sfx/Jingle_Achievement_00.wav")

	player_texture: rl.Texture2D = rl.LoadTexture("./sprites/player.png")
	background_texture: rl.Texture2D = rl.LoadTexture("./sprites/background.png")
	pipe_texture: rl.Texture2D = rl.LoadTexture("./sprites/pipe.png")

	rl.SetTargetFPS(60)

	player: Player = {{36, 36, 16 * SCALE, 16 * SCALE}, 0, rl.WHITE, player_texture}
	timer: Timer = {rl.GetTime(), rl.GetTime(), 0, 5}
	game_state: Game = .mainmenu

	pipelist: [dynamic]Pipe

	//Loading Score
	data, err := os.read_entire_file_from_path("./score.txt", context.temp_allocator)
	if (err == os.ERROR_NONE) {
		loaded_score, parse_ok := strconv.parse_int(string(data))
		if parse_ok {
			high_score = i64(loaded_score)
		}
	}

	//Write Score
	buf: [8]byte
	defer err = os.write_entire_file_from_string(
		"./score.txt",
		strconv.write_int(buf[:], high_score, 10),
	)


	for !rl.WindowShouldClose() {
		//Timer
		timer.current_time = rl.GetTime()
		timer.passed_time = timer.current_time - timer.start_time
		if (timer.passed_time >= timer.max_time) {
			timer.start_time = rl.GetTime()
			timer.current_time = rl.GetTime()
			timer.passed_time = 0
		}

		if (game_state == .mainmenu) {

			//Input
			if (rl.GetKeyPressed() != rl.KeyboardKey.KEY_NULL) {
				player.rectangle.y = 100
				game_state = .gameplay
			}

			//Draw
			rl.BeginDrawing()
			rl.ClearBackground(rl.BLUE)
			rl.DrawTextureRec(
				background_texture,
				{0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())},
				{0, 0},
				rl.WHITE,
			)
			rl.DrawText("Press Any Button to Start...", 200, 300, 40, rl.BLACK)
			rl.EndDrawing()
		}

		if (game_state == .gameplay) {

			dt := rl.GetFrameTime()

			//Input
			#partial switch rl.GetKeyPressed() {
			case .SPACE:
				player.velocity = JUMP_VELOCITY
				rl.PlaySound(jump_sfx)
			}

			//Update
			pipe_velocity = math.atan(f32(score)) + 100
			fmt.println(pipe_velocity)
			//Player
			player.rectangle.y += player.velocity * dt + 0.5 * GRAVITY * dt * dt
			player.velocity += GRAVITY * dt

			//Pipe
			if (len(pipelist) == 0) {
				temp_top_pipe: Pipe = {
					{900, 0, 100, rand.float32_range(0, 200)},
					rl.GREEN,
					false,
					pipe_texture,
				}
				temp_rand: f32 = rand.float32_range(temp_top_pipe.rectangle.height + 200, 600)
				temp_bottom_pipe: Pipe = {
					{900, temp_rand, 100, 800},
					rl.GREEN,
					false,
					pipe_texture,
				}
				append(&pipelist, temp_bottom_pipe)
				append(&pipelist, temp_top_pipe)
			}

			for &pipe in pipelist {
				pipe.rectangle.x -= pipe_velocity * dt
			}

			//Collision
			for &pipe, index in pipelist {
				if (rl.CheckCollisionRecs(pipe.rectangle, player.rectangle)) {
					set_highscore()
					clear(&pipelist)
					rl.PlaySound(death_sfx)
					game_state = .death
				}
				if (pipe.rectangle.x < -pipe.rectangle.width) {
					ordered_remove(&pipelist, index)
				}
				if (pipe.rectangle.x <= player.rectangle.x && pipe.is_scored == false) {
					score += 1
					pipe.is_scored = true
				}
			}
			//Floor Collision
			if (player.rectangle.y < 0 || player.rectangle.y > 600) {
				set_highscore()
				clear(&pipelist)
				rl.PlaySound(death_sfx)
				game_state = .death
			}


			//Draw
			rl.BeginDrawing()
			rl.ClearBackground(rl.BLUE)
			rl.DrawTextureRec(
				background_texture,
				{0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())},
				{0, 0},
				rl.WHITE,
			)
			rl.DrawTextureEx(
				player_texture,
				{player.rectangle.x, player.rectangle.y},
				0,
				SCALE,
				player.color,
			)
			for pipe in pipelist {
				draw_pipe(pipe)
			}
			rl.DrawText(rl.TextFormat("Score: %d", score), 0, 0, 20, rl.BLACK)
			rl.EndDrawing()
		}
		if (game_state == .death) {


			if (timer.passed_time == 0) {
				score = 0
				player.rectangle.y = 100
				game_state = .gameplay

			}

			//Draw
			rl.BeginDrawing()
			rl.ClearBackground(rl.BLUE)
			rl.DrawTextureRec(
				background_texture,
				{0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())},
				{0, 0},
				rl.WHITE,
			)
			rl.DrawText(
				rl.TextFormat("You died. \nScore: %d\nHigh Score: %d", score, high_score),
				200,
				300,
				40,
				rl.BLACK,
			)
			rl.EndDrawing()
		}
	}
}

set_highscore :: proc() {
	if (score > high_score) do high_score = score
}

draw_pipe :: proc(p: Pipe) {
	texture := p.texture
	source: rl.Rectangle = {0, 0, 16, 16}
	dest := p.rectangle
	origin: rl.Vector2 = {0, 0}
	rotation: f32 = 0
	tint := rl.WHITE
	rl.DrawTexturePro(texture, source, dest, origin, rotation, tint)
}

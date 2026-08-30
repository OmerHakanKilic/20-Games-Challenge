#include "raylib.h"
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <vector>

void handle_menu();
void handle_buttons();
void draw_buttons();
void init_gameplay();
void spawn_background_tiles();
void handle_gameplay();
void handle_input();
void spawn_cars();
void move_cars(float dt);
void draw_cars();
void draw_tiles();
void handle_death();

enum {
  MENU,
  GAMEPLAY,
  DEATH,
} gamestate;

enum Direction {
  UP,
  DOWN,
  RIGHT,
  LEFT,
};
struct Button {
  Rectangle source_rec;
  Rectangle dest_rec;
  Color color;
  Texture2D texture;
  bool is_pressed;
};

struct Entity {
  Rectangle source_rec;
  Rectangle dest_rec;
  Vector2 origin;
  float rotation;
  Color color;
  Texture2D texture;
};

// Globals
std::vector<Button> button_list;
Entity player;
std::vector<Entity> car_list;
std::vector<Entity> tile_list;
float SCALE = 50;

int main() {

  srand(time(0));

  InitWindow(14 * SCALE, 14 * SCALE, "Frogger");
  gamestate = MENU;

  Button but = {
      .source_rec = {0, 0, 72, 32},
      .dest_rec = {5 * SCALE, 6 * SCALE, 4 * SCALE, 2 * SCALE},
      .color = WHITE,
      .texture = LoadTexture("../assets/play-button.png"),
      .is_pressed = false,
  };

  button_list.push_back(but);

  while (!WindowShouldClose()) {
    switch (gamestate) {
    case MENU:
      handle_menu();
      break;
    case GAMEPLAY:
      handle_gameplay();
      break;
    case DEATH:
      handle_death();
      break;
    }
  }
}

void handle_menu() {
  // Update
  handle_buttons();
  // Draw
  BeginDrawing();
  ClearBackground(RAYWHITE);
  draw_buttons();
  EndDrawing();
}

void handle_buttons() {
  auto mouse_position = GetMousePosition();
  for (int i = 0; i < button_list.size(); i++) {

    if (CheckCollisionPointRec(mouse_position, button_list[i].dest_rec) &&
        IsMouseButtonDown(MOUSE_LEFT_BUTTON)) {
      button_list[i].is_pressed = true;
    }

    if (IsMouseButtonReleased(MOUSE_BUTTON_LEFT) &&
        button_list[i].is_pressed == true) {
      std::cout << "Clicked" << std::endl;
      init_gameplay();
      gamestate = GAMEPLAY;
      button_list[i].is_pressed = false;
    }
  }
}

void draw_buttons() {
  for (int i = 0; i < button_list.size(); i++) {
    DrawTexturePro(button_list[i].texture, button_list[i].source_rec,
                   button_list[i].dest_rec, {0, 0}, 0, button_list[i].color);
  }
}

void init_gameplay() {
  player = {
      .source_rec = {0, 0, 16, 16},
      .dest_rec = {7 * SCALE, 13 * SCALE + SCALE / 2, 1 * SCALE, 1 * SCALE},
      .origin = {(1 * SCALE) / 2, (1 * SCALE) / 2},
      .rotation = 0,
      .color = WHITE,
      .texture = LoadTexture("./../assets/player.png"),
  };
  spawn_cars();
  spawn_background_tiles();
}

void spawn_background_tiles() {
  Texture2D road_texture = LoadTexture("./../assets/road-tile.png");

  for (int i = 0; i < 14; i++) {
    for (int j = 0; j < 7; j++) {
      Entity temp = {
          .source_rec = {0, 0, 16, 32},
          .dest_rec = {i * SCALE, 2 * j * SCALE, 1 * SCALE, 2 * SCALE},
          .origin = {0, 0},
          .rotation = 0,
          .color = WHITE,
          .texture = road_texture,
      };

      tile_list.push_back(temp);
    }
  }
}

void handle_gameplay() {
  // Input
  handle_input();
  // Update
  float dt = GetFrameTime();
  move_cars(dt);
  // Draw
  BeginDrawing();
  ClearBackground(BLUE);
  draw_tiles();

  DrawTexturePro(player.texture, player.source_rec, player.dest_rec,
                 player.origin, player.rotation, player.color);
  draw_cars();
  DrawRectangleRec(player.dest_rec, RED);
  EndDrawing();
}

void handle_input() {
  if (IsKeyPressed(KEY_W)) {
    player.dest_rec.y -= SCALE;
    player.rotation = 0;
  }
  if (IsKeyPressed(KEY_S)) {
    player.dest_rec.y += SCALE;
    player.rotation = 180;
  }
  if (IsKeyPressed(KEY_A)) {
    player.dest_rec.x -= SCALE;
    player.rotation = 270;
  }
  if (IsKeyPressed(KEY_D)) {
    player.dest_rec.x += SCALE;
    player.rotation = 90;
  }
}

void spawn_cars() {
  float spawn_y = (rand() % 5) * SCALE;

  Entity temp = {
      .source_rec = {0, 0, 16},
      .dest_rec =
          {
              0,
              spawn_y,
              1 * SCALE,
              1 * SCALE,
          },
      .origin = {(16 * SCALE) / 2, (16 * SCALE) / 2},
      .color = WHITE,
      .texture = LoadTexture("./../assets/car.png"),
  };
  car_list.push_back(temp);
}

void draw_cars() {
  for (int i = 0; i < car_list.size(); i++) {
    DrawTexturePro(car_list[i].texture, {0, 0, 16, 16}, car_list[i].dest_rec,
                   {0, 0}, 0, car_list[i].color);
  }
}

void draw_tiles() {
  for (int i = 0; i < tile_list.size(); i++) {
    DrawTexturePro(tile_list[i].texture, tile_list[i].source_rec,
                   tile_list[i].dest_rec, tile_list[i].origin,
                   tile_list[i].rotation, tile_list[i].color);
  }
}

void move_cars(float dt) {
  for (int i = 0; i < car_list.size(); i++) {
    car_list[i].dest_rec.x += SCALE * dt;
  }
}

void handle_death() {}

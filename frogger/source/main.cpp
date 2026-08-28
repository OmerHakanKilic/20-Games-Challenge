#include "raylib.h"
#include <iostream>
#include <vector>

void handle_menu();
void handle_buttons();
void draw_buttons();
void init_gameplay();
void handle_gameplay();
void handle_input();
void handle_death();

enum {
  MENU,
  GAMEPLAY,
  DEATH,
} gamestate;

struct Button {
  Rectangle rec;
  Color color;
  Texture2D texture;
  bool is_pressed;
};

struct Entity {
  Rectangle rec;
  Color color;
  Texture2D texture;
};

// Globals
std::vector<Button> button_list;
Entity player;
float SCALE = 150;

int main() {

  InitWindow(9 * SCALE, 6 * SCALE, "Frogger");
  gamestate = MENU;

  Button but = {
      .rec = {360, 240, 4 * SCALE, 2 * SCALE},
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

    if (CheckCollisionPointRec(mouse_position, button_list[i].rec) &&
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
    DrawTexturePro(button_list[i].texture, {0, 0, 72, 32}, button_list[i].rec,
                   {0, 0}, 0, button_list[i].color);
  }
}

void init_gameplay() {
  player = {
      .rec = {200, 200, 1 * SCALE, 1 * SCALE},
      .color = WHITE,
      .texture = LoadTexture("./../assets/player.png"),
  };
}

void handle_gameplay() {
  // Input
  handle_input();
  // Update

  // Draw
  BeginDrawing();
  ClearBackground(BLUE);
  DrawTexturePro(player.texture, {0, 0, 16, 16}, player.rec, {0, 0}, 0,
                 player.color);
  EndDrawing();
}

void handle_input() {
  if (IsKeyReleased(KEY_W)) {
    player.rec.y -= SCALE;
  }
  if (IsKeyReleased(KEY_S)) {
    player.rec.y += SCALE;
  }
}

void handle_death() {}

#include <raylib.h>
#include <stdlib.h>
#include <unistd.h>

const int WINDOW_LENGHT = 800;
const int WINDOW_HEIGHT = 800;
const int SCREEN_SIZE = WINDOW_HEIGHT * WINDOW_LENGHT;
const Color DEAD_COLOR = DARKGRAY;
const Color ALIVE_COLOR = LIGHTGRAY;

enum State { DEAD, ALIVE };

typedef struct {
  Vector2 position;
  enum State pixel_state;
} Pixel;

void init_gosper_gun(Pixel *array) {
  int coords[][2] = {
      {10, 30}, {11, 28}, {11, 30}, {12, 18}, {12, 19}, {12, 26},
      {12, 27}, {12, 40}, {12, 41}, {13, 17}, {13, 21}, {13, 26},
      {13, 27}, {13, 40}, {13, 41}, {14, 6},  {14, 7},  {14, 16},
      {14, 22}, {14, 26}, {14, 27}, {15, 6},  {15, 7},  {15, 16},
      {15, 20}, {15, 22}, {15, 23}, {15, 28}, {15, 30}, {16, 16},
      {16, 22}, {16, 30}, {17, 17}, {17, 21}, {18, 18}, {18, 19}};
  int n = sizeof(coords) / sizeof(coords[0]);
  for (int i = 0; i < n; i++)
    array[(coords[i][0] * WINDOW_LENGHT) + coords[i][1]].pixel_state = ALIVE;
}

void init_pulsar(Pixel *array, int baseY, int baseX) {
  int offsets[][2] = {
      {0, 2}, {0, 3},  {0, 4},  {0, 8},  {0, 9},  {0, 10}, {5, 2},  {5, 3},
      {5, 4}, {5, 8},  {5, 9},  {5, 10}, {7, 2},  {7, 3},  {7, 4},  {7, 8},
      {7, 9}, {7, 10}, {12, 2}, {12, 3}, {12, 4}, {12, 8}, {12, 9}, {12, 10},
      {2, 0}, {3, 0},  {4, 0},  {8, 0},  {9, 0},  {10, 0}, {2, 5},  {3, 5},
      {4, 5}, {8, 5},  {9, 5},  {10, 5}, {2, 7},  {3, 7},  {4, 7},  {8, 7},
      {9, 7}, {10, 7}, {2, 12}, {3, 12}, {4, 12}, {8, 12}, {9, 12}, {10, 12}};
  int n = sizeof(offsets) / sizeof(offsets[0]);
  for (int i = 0; i < n; i++) {
    int y = baseY + offsets[i][0];
    int x = baseX + offsets[i][1];
    array[(y * WINDOW_LENGHT) + x].pixel_state = ALIVE;
  }
}

void init_diehard(Pixel *array, int baseY, int baseX) {
  int coords[][2] = {{0, 6}, {1, 0}, {1, 1}, {2, 1}, {2, 5}, {2, 6}, {2, 7}};
  int n = sizeof(coords) / sizeof(coords[0]);
  for (int i = 0; i < n; i++) {
    int y = baseY + coords[i][0];
    int x = baseX + coords[i][1];
    array[(y * WINDOW_LENGHT) + x].pixel_state = ALIVE;
  }
}

void init_acorn(Pixel *array, int baseY, int baseX) {
  int coords[][2] = {{0, 1}, {1, 3}, {2, 0}, {2, 1}, {2, 4}, {2, 5}, {2, 6}};
  int n = sizeof(coords) / sizeof(coords[0]);
  for (int i = 0; i < n; i++) {
    int y = baseY + coords[i][0];
    int x = baseX + coords[i][1];
    array[(y * WINDOW_LENGHT) + x].pixel_state = ALIVE;
  }
}

void init_pixel_array(Pixel *array, int pattern) {

  for (int i = 0; i < SCREEN_SIZE; i++) {
    array[i].position =
        (Vector2){(float)(i % WINDOW_LENGHT), (float)i / WINDOW_LENGHT};
    array[i].pixel_state = DEAD;
  }
  switch (pattern) {
  case 1:
    init_gosper_gun(array);
    break;
  case 2:
    init_pulsar(array, 300, 300);
    break;
  case 3:
    init_diehard(array, 300, 300);
    break;
  case 4:
    init_acorn(array, 300, 300);
    break;
  default:
      init_gosper_gun(array);
      break;
  }
}

enum State check_neighboorhood(Pixel *neighboorhood, Pixel *target) {

  int number_of_alive_neighboors = 0;

  for (int i = 0; i < 8; i++) {
    if (neighboorhood[i].pixel_state == ALIVE)
      number_of_alive_neighboors++;
  }

  if (target->pixel_state == DEAD) {
    if (number_of_alive_neighboors == 3)
      return ALIVE;
    else
      return DEAD;
  } else {
    if (number_of_alive_neighboors == 2 || number_of_alive_neighboors == 3)
      return ALIVE;
    else
      return DEAD;
  }
}
void update_pixels(Pixel *array, Pixel *buffer_array) {

  for (int i = 0; i < SCREEN_SIZE; i++) {
    buffer_array[i] = array[i];
  }

  for (int i = 0; i < SCREEN_SIZE; i++) {
    Pixel neighboorhood[8] = {0};

    int row = i / WINDOW_LENGHT;
    int col = i % WINDOW_LENGHT;

    if (row > 0 && col > 0)
      neighboorhood[0] = array[i - WINDOW_LENGHT - 1];
    else
      neighboorhood[0].pixel_state = DEAD;

    if (row > 0)
      neighboorhood[1] = array[i - WINDOW_LENGHT];
    else
      neighboorhood[1].pixel_state = DEAD;

    if (row > 0 && col < WINDOW_LENGHT - 1)
      neighboorhood[2] = array[i - WINDOW_LENGHT + 1];
    else
      neighboorhood[2].pixel_state = DEAD;

    if (col > 0)
      neighboorhood[3] = array[i - 1];
    else
      neighboorhood[3].pixel_state = DEAD;

    if (col < WINDOW_LENGHT - 1)
      neighboorhood[4] = array[i + 1];
    else
      neighboorhood[4].pixel_state = DEAD;

    if (row < WINDOW_HEIGHT - 1 && col > 0)
      neighboorhood[5] = array[i + WINDOW_LENGHT - 1];
    else
      neighboorhood[5].pixel_state = DEAD;

    if (row < WINDOW_HEIGHT - 1)
      neighboorhood[6] = array[i + WINDOW_LENGHT];
    else
      neighboorhood[6].pixel_state = DEAD;

    if (row < WINDOW_HEIGHT - 1 && col < WINDOW_LENGHT - 1)
      neighboorhood[7] = array[i + WINDOW_LENGHT + 1];
    else
      neighboorhood[7].pixel_state = DEAD;

    buffer_array[i].pixel_state = check_neighboorhood(neighboorhood, &array[i]);
  }

  for (int i = 0; i < SCREEN_SIZE; i++) {
    array[i].pixel_state = buffer_array[i].pixel_state;
  }
}
void draw_pixels(Pixel *array) {

  for (int i = 0; i < SCREEN_SIZE; i++) {
    if (array[i].pixel_state == ALIVE) {
      DrawPixelV(array[i].position, ALIVE_COLOR);
    } else {
      DrawPixelV(array[i].position, DEAD_COLOR);
    }
  }
}

int main(int argc, char *argv[]) {
  bool game_state = false; // if true it is game if false it is menu
  int pattern = 0;
  if (argc == 2) {
    pattern = atoi(argv[1]);
  }
  SetTargetFPS(60);
  InitWindow(WINDOW_LENGHT, WINDOW_HEIGHT, "Game of Life");
  Pixel *pixel_array = malloc(SCREEN_SIZE * sizeof(Pixel));
  Pixel *buffer_array = malloc(SCREEN_SIZE * sizeof(Pixel));
  if (pixel_array == NULL || buffer_array == NULL) {
    // Handle memory allocation failure
    return 1;
  }
  init_pixel_array(pixel_array, pattern);
  while (!WindowShouldClose()) {
    update_pixels(pixel_array, buffer_array);
    BeginDrawing();
    ClearBackground(RED);
    draw_pixels(pixel_array);
    EndDrawing();
  }
  CloseWindow();
  free(pixel_array);
  free(buffer_array);
  return 0;
}

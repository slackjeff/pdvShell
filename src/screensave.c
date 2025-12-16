#include <stdio.h>
#include <stdlib.h>
#include <wchar.h>
#include <locale.h>
#include <unistd.h>
#include <sys/ioctl.h>

/* =========================
   Estruturas
   ========================= */

typedef struct {
  wchar_t ch;
} Cell;

typedef struct {
  int rows;
  int cols;
  Cell *cells;
} Screen;

/* =========================
   Core de tela
   ========================= */

Screen *screen_create(int rows, int cols) {
  Screen *s = malloc(sizeof(Screen));
  s->rows = rows;
  s->cols = cols;
  s->cells = calloc(rows * cols, sizeof(Cell));
  return s;
}

void screen_destroy(Screen *s) {
  free(s->cells);
  free(s);
}

void screen_put(Screen *s, int r, int c, wchar_t ch) {
  if (r < 0 || c < 0 || r >= s->rows || c >= s->cols)
    return;
  s->cells[r * s->cols + c].ch = ch;
}

void screen_render(Screen *s) {
  wprintf(L"\033[H");
  for (int r = 0; r < s->rows; r++) {
    for (int c = 0; c < s->cols; c++) {
      wchar_t ch = s->cells[r * s->cols + c].ch;
      wprintf(L"%lc", ch ? ch : L' ');
    }
    wprintf(L"\n");
  }
  fflush(stdout);
}

/* =========================
   Save / Restore
   ========================= */

Cell *screen_save(Screen *s, int r1, int c1, int r2, int c2) {
  int h = r2 - r1 + 1;
  int w = c2 - c1 + 1;

  Cell *buf = malloc(h * w * sizeof(Cell));
  int i = 0;

  for (int r = 0; r < h; r++)
    for (int c = 0; c < w; c++)
      buf[i++] = s->cells[(r1 + r) * s->cols + (c1 + c)];

  return buf;
}

void screen_restore(Screen *s, int r1, int c1, int r2, int c2, Cell *buf) {
  int h = r2 - r1 + 1;
  int w = c2 - c1 + 1;
  int i = 0;

  for (int r = 0; r < h; r++)
    for (int c = 0; c < w; c++)
      s->cells[(r1 + r) * s->cols + (c1 + c)] = buf[i++];

  free(buf);
}

/* =========================
   Box gráfico
   ========================= */

void draw_box(Screen *s, int r, int c, int h, int w) {
  for (int i = 0; i < w; i++) {
    screen_put(s, r,         c + i, L'─');
    screen_put(s, r + h - 1, c + i, L'─');
  }
  for (int i = 0; i < h; i++) {
    screen_put(s, r + i, c,         L'│');
    screen_put(s, r + i, c + w - 1, L'│');
  }

  screen_put(s, r,         c,         L'┌');
  screen_put(s, r,         c + w - 1, L'┐');
  screen_put(s, r + h - 1, c,         L'└');
  screen_put(s, r + h - 1, c + w - 1, L'┘');
}

void draw_text(Screen *s, int r, int c, const wchar_t *txt) {
  for (int i = 0; txt[i]; i++)
    screen_put(s, r, c + i, txt[i]);
}

/* =========================
   MAIN
   ========================= */

int main(int argc, char *argv[]) {
  setlocale(LC_ALL, "");

  const wchar_t *msg = L"Opção inválida";
  if (argc > 1) {
    static wchar_t wmsg[256];
    mbstowcs(wmsg, argv[1], 255);
    msg = wmsg;
  }

  struct winsize ws;
  ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws);

  Screen *scr = screen_create(ws.ws_row, ws.ws_col);

  int w = wcslen(msg) + 4;
  int h = 3;
  int r = (scr->rows - h) / 2;
  int c = (scr->cols - w) / 2;

  Cell *bak = screen_save(scr, r, c, r + h - 1, c + w - 1);

  draw_box(scr, r, c, h, w);
  draw_text(scr, r + 1, c + 2, msg);

  screen_render(scr);
  getchar();

  screen_restore(scr, r, c, r + h - 1, c + w - 1, bak);
  screen_render(scr);

  screen_destroy(scr);
  return 0;
}

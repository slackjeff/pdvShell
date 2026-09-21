#include <ncurses.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  const char *msg = (argc > 1) ? argv[1] : "Mensagem";

  /* inicializa ncurses */
  initscr();
  cbreak();
  noecho();
  keypad(stdscr, TRUE);
  curs_set(0);

  /* limpa buffer interno do ncurses (NÃO a tela real) */
  clear();
  refresh();

  int rows, cols;
  getmaxyx(stdscr, rows, cols);

  int h = 5;
  int w = (int)strlen(msg) + 6;
  if (w > cols - 4) w = cols - 4;

  int y = (rows - h) / 2;
  int x = (cols - w) / 2;

  WINDOW *win = newwin(h, w, y, x);
  box(win, 0, 0);

  mvwprintw(win, 2, 3, "%.*s", w - 6, msg);
  wrefresh(win);

  /* limpa ENTER pendente */
  flushinp();
  wgetch(win);

  /* encerra ncurses */
  delwin(win);
  endwin();

  return 0;
}

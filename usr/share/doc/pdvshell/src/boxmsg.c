#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>

/* controle de terminal */
static struct termios oldt;

void raw_on(void) {
  struct termios newt;
  tcgetattr(STDIN_FILENO, &oldt);
  newt = oldt;
  newt.c_lflag &= ~(ICANON | ECHO);
  tcsetattr(STDIN_FILENO, TCSANOW, &newt);
}

void raw_off(void) {
  tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
}

/* move cursor */
void cup(int r, int c) {
  printf("\033[%d;%dH", r, c);
}

/* repete caractere */
void repeat(const char *ch, int n) {
  for (int i = 0; i < n; i++)
    fputs(ch, stdout);
}

int main(int argc, char *argv[]) {
  const char *msg = (argc > 1) ? argv[1] : "Mensagem";

  struct winsize ws;
  ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws);

  int rows = ws.ws_row;
  int cols = ws.ws_col;

  int msglen = strlen(msg);
  int w = msglen + 4;
  int h = 3;

  int r = (rows - h) / 2;
  int c = (cols - w) / 2;

  raw_on();

  /* topo */
  cup(r, c);
  fputs("┌", stdout);
  repeat("─", w - 2);
  fputs("┐", stdout);

  /* meio */
  cup(r + 1, c);
  fputs("│ ", stdout);
  fputs(msg, stdout);
  fputs(" │", stdout);

  /* fundo */
  cup(r + 2, c);
  fputs("└", stdout);
  repeat("─", w - 2);
  fputs("┘", stdout);

  fflush(stdout);

  /* espera tecla */
  getchar();

  /* apaga box */
  for (int i = 0; i < h; i++) {
    cup(r + i, c);
    for (int j = 0; j < w; j++)
      putchar(' ');
  }

  fflush(stdout);
  raw_off();

  return 0;
}

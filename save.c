// save.c, Copyright (c) 2023 Vilmar Catafesta <vcatafesta@gmail.com>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <ncurses.h>
#include <stdlib.h>

#define BLACK        "\033[30m"
#define RED          "\033[31m"
#define GREEN        "\033[32m"
#define YELLOW       "\033[33m"
#define BLUE         "\033[34m"
#define MAGENTA      "\033[35m"
#define CYAN         "\033[36m"
#define WHITE        "\033[37m"
#define GRAY         "\033[90m"
#define LIGHTWHITE   "\033[97m"
#define LIGHTGRAY    "\033[37m"
#define LIGHTRED     "\033[91m"
#define LIGHTGREEN   "\033[92m"
#define LIGHTYELLOW  "\033[93m"
#define LIGHTBLUE    "\033[94m"
#define LIGHTMAGENTA "\033[95m"
#define LIGHTCYAN    "\033[96m"
#define RESET        "\033[0m"
#define BOLD         "\033[1m"
#define FAINT        "\033[2m"
#define ITALIC       "\033[3m"
#define UNDERLINE    "\033[4m"
#define BLINK        "\033[5m"
#define INVERTED     "\033[7m"
#define HIDDEN       "\033[8m"

void salvarTela(FILE *arquivo) {
    if (initscr() == NULL) {
        perror("Falha ao inicializar ncurses");
        exit(EXIT_FAILURE);
    }

    // Salva o conteúdo do terminal no arquivo
    putwin(stdscr, arquivo);
    endwin();
}

void restaurarTela(FILE *arquivo) {
    if (initscr() == NULL) {
        perror("Falha ao inicializar ncurses");
        exit(EXIT_FAILURE);
    }

    // Restaura o conteúdo do terminal a partir do arquivo
    WINDOW *win = getwin(arquivo);
    wrefresh(win);
    endwin();
}

int main() {
   printf("%ssave.c, Copyright (c) 2023 Vilmar Catafesta <vcatafesta@gmail.com>%s\n", RED, RESET);
   printf("%sHello World\n%s", GREEN, RESET);
    FILE *arquivo = fopen("tela_salva", "w");

    if (arquivo == NULL) {
        perror("Falha ao abrir o arquivo para salvar a tela");
        return EXIT_FAILURE;
    }

    // Salva o estado atual do terminal
	salvarTela(arquivo);

    // Seu código aqui (pode ser um comando ou interação do usuário)

    // Restaura o estado do terminal
    fseek(arquivo, 0, SEEK_SET);
    restaurarTela(arquivo);

    fclose(arquivo);

    return EXIT_SUCCESS;
}

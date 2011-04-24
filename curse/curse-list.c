// reference: http://www.captain.at/howto-curses-example.php

#include <time.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <curses.h>

#define DEBUG true

#define CANCEL 0

#define KEY_ENTER 0xA
#define KEY_ESCAPE 0x1B
#define KEY_ARROW_UP 0x41
#define KEY_ARROW_DOWN 0x42

#define KEY_J 0x6A
#define KEY_K 0x6B
#define KEY_Q 0x71

static WINDOW* mainwnd;
static WINDOW* screen;

void printUsage(int argc, char** argv)
{
    printf("%s <list>", argv[0]);
}


void init(int argc, char** argv)
{
    mainwnd = initscr();
    noecho();
    cbreak();
    nodelay(mainwnd, true);
    refresh();
    screen = newwin(argc + 1, 80, 1, 1);
    //box(screen, ACS_VLINE, ACS_HLINE);
}

static int cursor = 1;
static void update_display(int argc, char** argv) {

    curs_set(0);
    mvwprintw(screen, 1, 6, "%s", "make a choice");
    for (int i = 1 ; i < argc; i++)
    {
        char* star;
        if (i == cursor)
            star = "*";
        else
            star = " ";
        mvwprintw(screen, i + 1, 6, "%s %2d %s", star, i, argv[i]);
    }
    wrefresh(screen);
    refresh();
}

void deinit()
{
    endwin();
}

/*
 *  Return false if its end session. Else return true if you want to continue.
 */
bool handle_keypress(int argc, char** argv)
{
    char c = getch();
    if (c == -1)
        return true;

    if (DEBUG)
        printf("%i, %X, %i", (c == KEY_ESCAPE), c, c);

    // move up
    if (c == KEY_ARROW_UP || c ==KEY_K)
        if (cursor > 1)
        {
            cursor--;
            return true;
        }

    // move down
    if (c == KEY_ARROW_DOWN || c == KEY_J)
        if (cursor <= argc)
        {
            cursor++;
            return true;
        }

    // select choice
    if (c == KEY_ENTER)
        return false;

    // escape or q
    if (c == KEY_Q)
    {
        cursor = CANCEL;
        return false;
    }
    if (c == KEY_ESCAPE)
    {
        c = getch();
        // HACK a real escape trigger a getch of -1 after, not the arrow
        if (c == -1)
        {
            cursor = CANCEL;
            return false;
        }
    }

    return true;
}

int main(int argc, char** argv)
{

    // must have arguments
    if (argc == 1)
    {
        printUsage(argc, argv);
        return -1;
    }

    // initialise window
    init(argc, argv);

    // loop for keypress
    bool loop = true;
    while (loop)
    {
        loop = handle_keypress(argc, argv);

        update_display(argc, argv);
        usleep(100);
    }

    // finaly deinit the window and print user choice
    deinit();
    if (cursor != CANCEL)
        printf("%s\n", argv[cursor]);

    return 0;
}

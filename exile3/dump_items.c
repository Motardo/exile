/*
This program will read all the game items from EXILE3.EXE and print them to
stdout as a CSV file.

Usage: gcc dump_items.c && ./a.out ~/dos/c/EXILE3/EXILE3.EXE > e3items.csv

There are over 400 items in 4 different data blocks. Each item record
is 59 bytes. The item records are printed to stdout one record per
line with fields separated by commas.
*/

#include <fcntl.h>  // open
#include <unistd.h> // read, lseek
#include <stdio.h>  // printf
#include <err.h>    // err, errx

// The items are in 4 blocks at different offset in EXILE3.EXE
#define NUM_ITEM_BLOCKS 4
// Each block {offset, num_items}
int item_blocks[NUM_ITEM_BLOCKS][2] =
  {{96768,   32},  // gold, food, misc; 32 records
   {98833,   87},  // weapons; 87 records
   {104084,  62},  // armor, tools; 62 records
   {107860, 223}}; // magic items; 223 records

#define ITEM_SIZE 59
typedef struct item_record {
  short variety;
  short level;
  char encumb, bonus, protection, charges, melee_t;
  unsigned char pic, ability, combine, unk1;
  unsigned char lval, hval;
  char id, magic;
  unsigned char weight, unk2;
  char fullname[25];
  char shortname[15];
} item_record;

// Read an item from the given open file and print the fields to stdout
void dump_item(int fd) {
  item_record i;

  if (read(fd, (char*)&i, ITEM_SIZE) != ITEM_SIZE) err(1, "%s", __FUNCTION__);

  printf("%s,%s,%d,", i.fullname, i.shortname, i.lval + 256 * i.hval);
  printf("%d,%d,%d,%d,%d,", i.variety, i.level, i.encumb, i.bonus, i.protection);
  printf("%d,%d,%d,%d,%d,", i.charges, i.melee_t, i.pic, i.ability, i.combine);
  printf("%d,%d,%d,%d,%d", i.unk1, i.unk2, i.id, i.magic, i.weight);
  printf("\n");
}

int main(int argc, char* argv[]) {
  int fd;

  // Try to open the argument specified file
  if (argc != 2) errx(2, "%s", "Usage: command path/to/EXILE3.EXE");
  if ((fd = open(argv[1], O_RDONLY)) == -1) err(3, "%s", argv[1]);

  // Print the CSV header row
  printf("%s,%s,%s,", "fullname", "shortname", "value");
  printf("%s,%s,%s,%s,%s,", "variety", "level", "encumb", "bonus", "protection");
  printf("%s,%s,%s,%s,%s,", "charges", "melee", "pic", "ability", "combine");
  printf("%s,%s,%s,%s,%s", "unk1", "unk2", "id", "magic", "weight");
  printf("\n");

  // Read the items and print them
  for (int i = 0; i < NUM_ITEM_BLOCKS; i++) {
    if ((lseek(fd, item_blocks[i][0], SEEK_SET)) == -1) err(5, "%s", argv[1]);
    for (int j = 0; j < item_blocks[i][1]; j++) {
      dump_item(fd);
    }
  }
}

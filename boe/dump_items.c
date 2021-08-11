/*
This program will read all the game items from a scenario.EXS file and print
them to stdout as a CSV file.

Usage: gcc dump_items.c && ./a.out ~/dos/c/BLADEXIL/BLADSCEN/VALLEYDY.EXS >valley-items.csv
*/

#include <fcntl.h>  // open
#include <unistd.h> // read, lseek
#include <stdio.h>  // printf
#include <err.h>    // err, errx

// The items are in the .EXS file
#define ITEM_OFFSET 0xa3d6
typedef struct {
	short variety, level;
	char encumb, bonus, protection, charges, melee_t, magic_use_type;
	unsigned char pic, ability, ability_strength, type_flag, is_special, a;
	unsigned char lval, hval;
	unsigned char weight, special_class;
	unsigned char x_loc, y_loc;
	char fullname[25], shortname[15];
	unsigned char treas_class, item_properties, reserved1, reserved2;
} item_record;

#define ITEM_SIZE 66

// Read an item from the given open file and print the fields to stdout
void dump_item(int fd) {
  item_record i;

  if (read(fd, (char*)&i, ITEM_SIZE) != ITEM_SIZE) err(1, "%s", __FUNCTION__);

  printf("%s,%s,%d,", i.fullname, i.shortname, i.lval + 256 * i.hval);
  printf("%d,%d,%d,%d,%d,", i.variety, i.level, i.encumb, i.bonus, i.protection);
  printf("%d,%d,%d,%d,%d,", i.charges, i.melee_t, i.pic, i.ability, i.ability_strength);
  printf("%d,%d,%d,%d,%d,", i.treas_class, i.item_properties, i.type_flag, i.is_special, i.weight);
  printf("%d,%d,%d,%d,%d,", i.special_class, i.magic_use_type, i.a, i.x_loc, i.y_loc);
  printf("%d,%d\n", i.reserved1, i.reserved2);
}

int main(int argc, char* argv[]) {
  int fd;

  // Try to open the argument specified file
  if (argc != 2) errx(2, "%s", "Usage: command path/to/SCEN.EXS");
  if ((fd = open(argv[1], O_RDONLY)) == -1) err(3, "%s", argv[1]);

  // Print the CSV header row
  printf("%s,%s,%s,", "fullname", "shortname", "value");
  printf("%s,%s,%s,%s,%s,", "variety", "level", "encumb", "bonus", "protection");
  printf("%s,%s,%s,%s,%s,", "charges", "melee", "pic", "ability", "ability_strength");
  printf("%s,%s,%s,%s,%s,", "treas_class", "item_properties", "type_flag", "is_special", "weight");
  printf("%s,%s,%s,%s,%s,", "special_class", "magic_use_type", "a", "x_loc", "y_loc");
  printf("%s,%s\n", "reserved1", "reserved2");

  // Read the items and print them
    if ((lseek(fd, ITEM_OFFSET, SEEK_SET)) == -1) err(5, "%s", argv[1]);
    for (int j = 0; j < 400; j++) {
      dump_item(fd);
    }
}

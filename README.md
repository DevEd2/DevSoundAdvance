# DevSound Advance
Work in progress sound driver for Game Boy Advance. Currently not in a working state.

## Dependencies
- devkitPro
- devkitPro's gba-dev package
- GNU Make

## Building
Just run `make`.

## "API" "documentation"
NOTE: Make sure to `#include "devsound.h"`.

To initialize sound: `DS_Init();`

To load a song (replace `id` with the ID of the song to play): `DS_LoadSong(id);`

To stop a song: `DS_Stop();`

Call this every VBlank to update sound registers: `DS_Update();`

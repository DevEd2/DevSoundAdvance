// This is just a simple demo ROM for DevSound Advance.
// Don't expect 

#include <tonc.h>
#include "devsound.h"

int main()
{
	int frame=0;
	char strbuf[32];
	
	irq_init(NULL);
	irq_add(II_VBLANK, NULL);
	
	DS_LoadSong(MUS_TECHNO);
	
	REG_DISPCNT = DCNT_MODE0 | DCNT_BG0;
	
	tte_init_se_default(0, BG_CBB(0)|BG_SBB(31));
	
	tte_write("\nDevSound Advance Demo\nby DevEd\n");
	// TODO: Visualizer?
	
	while(1)
	{
		DS_Update();
		tte_write("#{P:0,0}");
		sprintf(strbuf, "%d", frame);
		tte_write(strbuf);
		frame++;
		VBlankIntrWait();
    }
}

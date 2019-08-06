#include "FionaVMD.h"
#include "FionaUT.h"

#include "VMD/VMDApp.h"
#include "VMD/vmd.h"
#include "VMD/P_UIVR.h"
#include "VMD/P_Tracker.h"
#include "VMD/P_Buttons.h"
#include "VMD/CommandQueue.h"

FionaVMD::FionaVMD() : FionaScene(),  vmdApp(0), m_buttons(0), initialized(false)
{

}

FionaVMD::~FionaVMD()
{
	if(vmdApp)
	{
		vmdApp->VMDexit("Exiting Fiona VMD...", 0, 2);
		delete vmdApp;
		vmdApp = 0;
	}

	VMDshutdown(0);
	
}

void FionaVMD::buttons(int button, int state)
{
	if(state == 0)
	{
		m_buttons &= ~(1<<button);
	}
	else
	{
		m_buttons |= (1<<button);
	}
}

void FionaVMD::executeCommand(const char *sCmd)
{
	//FionaScene::executeCommand(sCmd);

	if(vmdApp)
	{
		if (sCmd != 0 && strlen(sCmd) != 0)
		{
			//printf("Executing %s\n", sCmd);
			vmdApp->commandQueue->execute_command(sCmd);
			//vmdApp->commandQueue->execute_all();
		}
	}
}

bool FionaVMD::isRunning(void) const
{
	if(vmdApp)
	{
		return (vmdApp->exitFlag == 0);
	}

	return true;
}

void FionaVMD::render(void)
{
	if(vmdApp)
	{
		// read user-defined startup files
		if(!initialized)
		{
			VMDreadStartup(((FionaVMD*)scene)->vmdApp);
			initialized = true;
		}

		FionaScene::render();

		//VMDupdateFltk();
		// take over the console
		vmdApp->VMDupdate(VMD_CHECK_EVENTS);
	}
}

void FionaVMD::keyboard(unsigned int key, int x, int y)
{
	if(key == 27)
	{
		if(fionaNetSlave)
		{
			if(vmdApp)
			{
				printf("In VMD keyboard function\n");
				FionaUTExit(0);
				//vmdApp->exitFlag=1;
				//executeCommand("quit");
				//vmdApp->VMDexit("",0,2);
			}
		}
	}
}
#include "FionaVMDTracker.h"

#include "FionaVMD.h"
#include "VMD/VMDQuat.h"
#include "FionaUT.h"

FionaVMDTracker::FionaVMDTracker() : VMDTracker(), m_pScene(0)
{

}

FionaVMDTracker::~FionaVMDTracker()
{

}

int FionaVMDTracker::alive()
{
	return 1;
}

VMDTracker *FionaVMDTracker::clone()
{
	return new FionaVMDTracker();
}

const char *FionaVMDTracker::device_name() const
{
	return "LEL_Wand";
}

int FionaVMDTracker::do_start(const SensorConfig *config)
{
	return 1;
}

void FionaVMDTracker::update()
{
	if(m_pScene == 0)
	{
		m_pScene = (FionaVMD*)scene;
	}

	//grab info from fiona and set values here..
	if(m_pScene != 0)
	{
		jvec3 vPos;
		m_pScene->getWandWorldSpace(vPos, false);
		pos[0] = vPos.x;
		pos[1] = vPos.y;
		pos[2] = vPos.z;
		quat vRot;
		m_pScene->getWandRotWorldSpace(vRot);
		Quat q(-vRot.z, vRot.y, vRot.x, vRot.w);
		q.rotate('y', 90.f);
		q.printMatrix(orient->mat);
	}
}

//FionaVMDButtons....
FionaVMDButtons::FionaVMDButtons() : Buttons(), m_pScene(0)
{
	used.append(0);
	used.append(1);
	used.append(2);
	used.append(3);
	used.append(4);
	used.append(5);
}

FionaVMDButtons::~FionaVMDButtons()
{

}

int FionaVMDButtons::alive()
{
	return 1;
}

Buttons *FionaVMDButtons::clone()
{
	return new FionaVMDButtons();
}

const char *FionaVMDButtons::device_name() const
{
	return "LEL_Wand_Buttons";
}

int FionaVMDButtons::do_start(const SensorConfig *)
{
	return 1;
}

void FionaVMDButtons::update()
{
	if(m_pScene == 0)
	{
		m_pScene = (FionaVMD*)scene;
	}

	if(m_pScene != 0)
	{
		//set our 6 wand buttons from fiona to the structure used by VMD.
		int b = m_pScene->getButtons();
		for(int i = 0; i < 6; ++i)
		{
			(b & (1<<i)) ? stat[i] = 1 : stat[i] = 0;
		}
	}
}


#ifndef FIONAVMDTRACKER_H_
#define FIONAVMDTRACKER_H_

#include "VMD/P_Tracker.h"

class FionaVMD;

class FionaVMDTracker : public VMDTracker
{
public:
	FionaVMDTracker();
	virtual ~FionaVMDTracker();

	virtual const char *device_name() const;
	virtual VMDTracker *clone();
	
	virtual void update();
	virtual int alive();

protected:
	virtual int do_start(const SensorConfig *config);

private:
	FionaVMD *m_pScene;
};

#include "VMD/P_Buttons.h"

class FionaVMDButtons : public Buttons
{
public:
	FionaVMDButtons();
	virtual ~FionaVMDButtons();

	virtual const char *device_name() const;
	virtual Buttons *clone();
	
	virtual void update();
	virtual int alive();

protected:
	virtual int do_start(const SensorConfig *);
private:
	FionaVMD *m_pScene;
};

#endif
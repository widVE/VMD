#ifndef FIONAVMDDISPLAYDEVICE_H_
#define FIONAVMDDISPLAYDEVICE_H_

#include "VMD/OpenGLRenderer.h"

class FionaVMD;

class FionaVMDDisplayDevice : public OpenGLRenderer
{
public:
	FionaVMDDisplayDevice();
	virtual ~FionaVMDDisplayDevice();

	virtual void clear(void);					 ///< let Fiona handle clearing
	virtual void set_stereo_mode(int = 0);       ///< ignore stereo mode changes
	virtual void render(const VMDDisplayList *); ///< FreeVR renderer + init chk
	virtual void normal(void);                   ///< prevent view mode changes
	virtual void update(int do_update = TRUE);   ///< prevent buffer swaps 

protected:

private:
	int doneGLInit;                ///< have we initialized the graphics yet?
	void fiona_gl_init_fn(void);  ///< setup graphics state on FreeVR displays
  
};

#endif
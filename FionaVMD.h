#ifndef _FIONAVMD_H_
#define _FIONAVMD_H_

#include "FionaScene.h"

class VMDApp;

class FionaVMD : public FionaScene
{
public:
	FionaVMD();
	virtual ~FionaVMD();

	virtual void	buttons(int button, int state);
	virtual void	executeCommand(const char *sCmd);
	virtual bool	isRunning(void) const;
	virtual void	render(void);
	virtual void	keyboard(unsigned int key, int x, int y);

	VMDApp *vmdApp;

	int				getButtons(void) const { return m_buttons; }

protected:

private:
	bool initialized;
	int	m_buttons;
};

#endif
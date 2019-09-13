//
//  main.cpp
//  FionaUT
//
//  Created by Hyun Joon Shin on 5/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

//	//disable warning about exception specification that visual c++ doesn't implement (gcc probably does) - voreen classes cause it

#define WITH_FIONA
#ifdef WIN32
#include "gl/glew.h"
#else
#include "glew/glew.h"
#endif

#include "FionaVMD.h"
#include "VMD/vmd.h"

#include "FionaUT.h"

#ifdef WIN32
#include "FionaUtil.h"
#endif
#include <Kit3D/glslUtils.h>
#include <Kit3D/glUtils.h>

class FionaScene;
FionaScene* scene = NULL;

extern bool cmp(const std::string& a, const std::string& b);
extern std::string getst(char* argv[], int& i, int argc);
/*static bool cmp(const char* a, const char* b)
{
	if( strlen(a)!=strlen(b) ) return 0;
	size_t len = MIN(strlen(a),strlen(b));
	for(size_t i=0; i<len; i++)
		if(toupper(a[i]) != toupper(b[i])) return 0;
	return 1;
}
*/
static bool cmpExt(const std::string& fn, const std::string& ext)
{
	std::string extt = fn.substr(fn.rfind('.')+1,100);
	std::cout<<"The extension: "<<extt<<std::endl;
	return cmp(ext.c_str(),extt.c_str());
}


jvec3 curJoy(0,0,0);
jvec3 pos(0,0,0);
quat ori(1,0,0,0);
//int		calibMode = 0;

void draw5Teapot(void) {
	static GLuint phongShader=0;
	static GLuint teapotList =0;

	if( FionaIsFirstOfCycle() )
	{
		pos+=jvec3(0,0,curJoy.z*0.01f);
		ori =exp(YAXIS*curJoy.x*0.01f)*ori;
	}
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glTranslate(-pos);
	glRotate(ori);
	glDisable(GL_CULL_FACE);
	glDepthFunc(GL_LESS);
	glLight(vec4(0,0,0,1),GL_LIGHT0,0xFF202020);
	glBindTexture(GL_TEXTURE_2D,0);
	jvec3 pos[5]={jvec3(0,0,-1.5),jvec3(-1.5,0,0),jvec3(1.5,0,0),jvec3(0,-1.5,0), jvec3(0,1.5,0)};
	if( teapotList <=0 )
	{
		teapotList = glGenLists(1);
		glNewList(teapotList,GL_COMPILE);
		//glutSolidTeapot(.65f);
		glEndList();
	}
	if( phongShader<=0 )
	{
		glewInit();
		std::string vshader = std::string(commonVShader());
		std::string fshader = coinFShader(PLASTICY,PHONG,false);
		phongShader = loadProgram(vshader,fshader,true);
	}
	glUseProgram(phongShader);
	glEnable(GL_DEPTH_TEST); glMat(0xFFFF8000,0xFFFFFFFF,0xFF404040);
	glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,10);
	for(int i=0;i<3; i++){ glPushMatrix(); glTranslate(pos[i]);
		//glutSolidTeapot(.65f);
		//glCallList(teapotList);
		glSphere(V3ID,.65);
		glPopMatrix();}
	glUseProgram(0);
}

enum APP_TYPE
{
	APP_TEAPOT = 0,
	APP_DEF_VMD = 1,
} type = APP_DEF_VMD;

void wandBtns(int button, int state, int idx)
{
	if(scene)
	{
		scene->buttons(button, state);
	}
}

void keyboard(unsigned int key, int x, int y)
{
	if(scene)
	{
		scene->keyboard(key, x, y);
	}
}

void joystick(int w, const vec4& v)
{
	if(scene) 
	{
		scene->updateJoystick(v);
	}
	curJoy = v;
}

void mouseBtns(int button, int state, int x, int y)
{
	if(scene)
	{
		scene->mouseCallback(button, state, x, y);
	}
}

void mouseMove(int x, int y) 
{
	if(scene)
	{
		scene->mouseMoveCallback(x,y);
	}
}

void tracker(int s,const jvec3& p, const quat& q)
{ 
	if(s==1 && scene)
	{
		scene->updateWand(p,q); 
	}
}

void preDisplay(float value)
{
	if(scene != 0)
	{
		scene->preRender(value);
	}
}

void postDisplay(void)
{
	if(scene != 0)
	{
		scene->postRender();
	}
}

void render(void)
{
	if(scene!=NULL) 
		scene->render();
	else 
		draw5Teapot();
}

/*void wiiFitCheck(void)
{
	if(fionaNetMaster || fionaConf.appType == FionaConfig::WINDOWED)
	{
		if(!balance_board.IsConnected())
		{
			bool bConnected = balance_board.Connect(wiimote::FIRST_AVAILABLE);
			if(bConnected)
			{
				balance_board.SetLEDs(0x0f);
			}
		}
		else
		{
			static int reCalibrated = 0;
			if(reCalibrated < 5)
			{
				balance_board.CalibrateAtRest();
				reCalibrated++;
			}

			balance_board.RefreshState();

			float fourWeights[4];
			fourWeights[0] = balance_board.BalanceBoard.Lb.BottomL;
			fourWeights[1] = balance_board.BalanceBoard.Lb.BottomR;
			fourWeights[2] = balance_board.BalanceBoard.Lb.TopL;
			fourWeights[3] = balance_board.BalanceBoard.Lb.TopR;
			
			//let's threshold the values since they always seem to have some value to them...
			for(int i = 0; i < 4; ++i)
			{
				if(fabs(fourWeights[i]) < 5.f)
				{
					fourWeights[i] = 0.f;
				}
			}

			//printf("Bottom Left: %f, Bottom Right: %f, Top Left: %f, Top Right: %f\n", fourWeights[0], fourWeights[1], fourWeights[2], fourWeights[3]);
			if(fionaConf.appType == FionaConfig::HEADNODE)
			{
				//pack this wii-fit data into a network packet..
				_FionaUTSyncSendWiiFit(fourWeights);
			}
		}
	}
}*/

void vmdFrameUpdate(float f)
{
	VMDupdateFltk();
	((FionaVMD*)scene)->vmdApp->VMDupdate(VMD_CHECK_EVENTS);
}

int main(int argc, char *argv[])
{
	glutInit(&argc,argv);
	float measuredIPD=63.5;
	int userID=0;
	bool writeFull=false;
	std::string fn;

	VMDinitialize(&argc, &argv, 0);

	const char *displayTypeName = VMDgetDisplayTypeName();
	int displayLoc[2], displaySize[2];
	VMDgetDisplayFrame(displayLoc, displaySize);

	scene = new FionaVMD();

	((FionaVMD*)scene)->vmdApp = new VMDApp(argc, argv, 0);
	((FionaVMD*)scene)->vmdApp->VMDinit(argc, argv, displayTypeName, displayLoc, displaySize);
	
	// read various application defaults
	VMDreadInit(((FionaVMD*)scene)->vmdApp);

	scene->navMode=WAND_MODEL;//KEYBOARD;
	
	if(fionaNetSlave || (fionaConf.appType == FionaConfig::DEVLAB))//WINDOWED))
	{
		printf("Making slave VMD...\n");

		glutInitDisplayMode(GLUT_RGB|GLUT_DOUBLE|GLUT_DEPTH);
	
		glutCreateWindow	("Window");
		glutDisplayFunc		(render);
		glutJoystickFunc	(joystick);
		glutMouseFunc		(mouseBtns);
		glutMotionFunc		(mouseMove);
		glutWandButtonFunc	(wandBtns);
		glutTrackerFunc		(tracker);
		glutKeyboardFunc	(keyboard);
		glutFrameFunc		(preDisplay);
		glutPostRender		(postDisplay);
	}
	else if(fionaNetMaster || (fionaConf.appType == FionaConfig::WINDOWED))
	{
		glutFrameFunc		(vmdFrameUpdate);
		glutJoystickFunc	(joystick);
		glutWandButtonFunc	(wandBtns);
		glutTrackerFunc		(tracker);
		glutPostRender		(postDisplay);
	}

	glutMainLoop();

	delete scene;

	return 0;
}

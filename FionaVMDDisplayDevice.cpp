/***************************************************************************
 * RCS INFORMATION:
 *
 *      $RCSfile: FionaVMDDisplayDevice.C,v $
 *      $Author: Ross Tredinnick $        $Locker:  $                $State: Exp $
 *      $Revision: 1.30 $      $Date: 2013/04/17 05:04:24 $
 *
 ***************************************************************************
 * DESCRIPTION:
 *
 * a Fiona specific display device for VMD
 ***************************************************************************/

//#include "Inform.h"
#include "FionaVMD.h"
#include "FionaUT.h"
#include "FionaVMDDisplayDevice.h"


// static string storage used for returning stereo modes
static const char *fionaStereoNameStr[1] = {"Fiona"};

static const char *glRenderNameStr[OPENGL_RENDER_MODES] =
{ "Normal",
  "GLSL",
  "Acrobat3D" }; 

static const char *glCacheNameStr[OPENGL_CACHE_MODES] =
{ "Off",
  "On" };

///////////////////////////////  constructor
FionaVMDDisplayDevice::FionaVMDDisplayDevice(void) : OpenGLRenderer("Fiona")
{  

  stereoNames = fionaStereoNameStr;
  stereoModes = 1;
  
  renderNames = glRenderNameStr;
  renderModes = OPENGL_RENDER_MODES;

  cacheNames = glCacheNameStr;
  cacheModes = OPENGL_CACHE_MODES;

  doneGLInit = FALSE;    
  num_display_processes  = 1;//vrContext->config->num_windows;

  // XXX migrated some initialization code into the constructor due
  //     to the order of initialization in CAVE/FreeVR builds
  aaAvailable = TRUE;               // enable antialiasing
  cueingAvailable = FALSE;          // disable depth cueing
  cullingAvailable = FALSE;         // disable culling
  ext->hasstereo = TRUE;            // stereo is on initially
  ext->stereodrawforced = FALSE;    // no need for force stereo draws

  //this stuff just gets over-written in setup_initial_opengl_state...?
  ogl_useblendedtrans = 0;
  ogl_transpass = 0;
  ogl_useglslshader = 0;
  ogl_acrobat3dcapture = 0;
  ogl_lightingenabled = 0;
  ogl_rendstateserial = 1;    // force GLSL update on 1st pass
  ogl_glslserial = 0;         // force GLSL update on 1st pass
  ogl_glsltoggle = 1;         // force GLSL update on 1st pass
  ogl_glslmaterialindex = -1; // force GLSL update on 1st pass
  ogl_glslprojectionmode = DisplayDevice::PERSPECTIVE;
  ogl_glsltexturemode = 0;    // initialize GLSL projection to off

}

///////////////////////////////  destructor
FionaVMDDisplayDevice::~FionaVMDDisplayDevice(void) {
  // nothing to do
}


/////////////////////////////  public routines  //////////////////////////

// set up the graphics on the seperate FreeVR displays
void FionaVMDDisplayDevice::fiona_gl_init_fn(void) {
  setup_initial_opengl_state();     // do all OpenGL setup/initialization now

  // follow up with mode settings
  aaAvailable = TRUE;               // enable antialiasing
  cueingAvailable = FALSE;          // disable depth cueing
  cullingAvailable = FALSE;         // disable culling
  ext->hasstereo = FALSE;            // stereo is off initially
  ext->stereodrawforced = FALSE;    // no need for force stereo draws

  //match with the fixed-function default light states
  ogl_lightstate[0] = 1;
  ogl_lightstate[1] = 1;

  glClearColor(0.0, 0.0, 0.0, 0.0); // set clear color to black

  aa_on();                          // force antialiasing on if possible
  //cueing_off();                     // force depth cueing off

  // set default settings
  set_sphere_mode(sphereMode);
  set_sphere_res(sphereRes);
  set_line_width(lineWidth);
  set_line_style(lineStyle);

  clear();                          // clear screen
  update();                         // swap buffers

  // we want the CAVE to be centered at the origin, and in the range -1, +1
  //(transMat.top()).translate(0.0, 3.0, -2.0);
  //(transMat.top()).scale(VMD_PI);

  doneGLInit = TRUE;                // only do this once
}

void FionaVMDDisplayDevice::clear(void)
{
	//let FionaUT clear not VMD..
}

void FionaVMDDisplayDevice::set_stereo_mode(int) {
  // cannot change to stereo mode in Fiona, it is setup at init time
}

void FionaVMDDisplayDevice::normal(void) {
  // prevent the OpenGLRenderer implementation of this routine
  // from overriding the projection matrices provided by the

}

int FionaVMDDisplayDevice::do_define_light(int n, float *color, float *position)
{
	//return OpenGLRenderer::do_define_light(n, color, position);

	/*jvec3 viewDir = fionaConf.headRot.rot(-ZAXIS);
	viewDir = fionaConf.camRot.rot(viewDir);
	viewDir = viewDir.normalize();

	glLightfv((GLenum)(GL_LIGHT0 + n), GL_POSITION, &ogl_lightpos[n][0]);

	ogl_rendstateserial++; // cause GLSL cached state to update when necessary
	_needRedraw = 1;
	return TRUE;*/

	float fEyeDir[3] = { 0.f, 0.f, -1.f };
	jvec3 viewDir = fionaConf.headRot.rot(-ZAXIS);
	viewDir = fionaConf.camRot.rot(viewDir);
	viewDir = viewDir.normalize();
	fEyeDir[0] = viewDir.x;
	fEyeDir[1] = viewDir.y;
	fEyeDir[2] = viewDir.z;

	int i;

	for (i = 0; i < 3; i++)  {
		ogl_lightcolor[n][i] = color[i];
		if (n == 0)
		{
			ogl_lightpos[n][i] = fEyeDir[i];
		}
		else
		{
			ogl_lightpos[n][i] = position[i];
		}
	}
	ogl_lightpos[n][3] = 0.0; // directional lights require w=0.0 otherwise
	// OpenGL assumes they are positional lights.
	ogl_lightcolor[n][3] = 1.0;

	// normalize the light direction vector
	vec_normalize(&ogl_lightpos[n][0]); // 4th element is left alone

	glLightfv((GLenum)(GL_LIGHT0 + n), GL_POSITION, &ogl_lightpos[n][0]);
	glLightfv((GLenum)(GL_LIGHT0 + n), GL_SPECULAR, &ogl_lightcolor[n][0]);

	ogl_rendstateserial++; // cause GLSL cached state to update when necessary
	_needRedraw = 1;
	return TRUE;
}

void FionaVMDDisplayDevice::update_shader_uniforms(void *voidshader, int forceupdate)
{
	OpenGLRenderer::update_shader_uniforms(voidshader, forceupdate);

#if defined(VMDUSEOPENGLSHADER)
	OpenGLShader *sh = (OpenGLShader *)voidshader;
	GLint loc;

	GLfloat eyePos[3];
	jvec3 vEye = fionaConf.camPos + fionaConf.camRot.rot(fionaConf.headPos);
	eyePos[0] = vEye.x;
	eyePos[1] = vEye.y;
	eyePos[2] = vEye.z;

	loc = GLGETUNIFORMLOCATIONARB(sh->ProgramObject, "eyePos");
	GLUNIFORM3FVARB(loc, 1, eyePos);

	GLfloat fEyeDir[3] = { 0.f, 0.f, -1.f };
	jvec3 viewDir = fionaConf.headRot.rot(-ZAXIS);
	viewDir = fionaConf.camRot.rot(viewDir);
	viewDir = viewDir.normalize();
	fEyeDir[0] = viewDir.x;
	fEyeDir[1] = viewDir.y;
	fEyeDir[2] = viewDir.z;

	loc = GLGETUNIFORMLOCATIONARB(sh->ProgramObject, "eyeDir");
	GLUNIFORM3FVARB(loc, 1, fEyeDir);
#endif
}

// special render routine to check for graphics initialization
void FionaVMDDisplayDevice::render(const VMDDisplayList *cmdlist) {
  if(!doneGLInit) {
    fiona_gl_init_fn();
  }

  // prepare for rendering
  //glPushMatrix();
  //multmatrix((transMat.top()));  // add our FreeVR adjustment transformation

  // update the cached transformation matrices for use in text display, etc.
  // In FreeVR, we have to do this separately for all of the processors.
  // Would be nice to do this outside of the render routine however,
  // amortized over several Displayables.
  glGetFloatv(GL_PROJECTION_MATRIX, ogl_pmatrix);
  glGetFloatv(GL_MODELVIEW_MATRIX, ogl_mvmatrix);
  ogl_textMat.identity();
  ogl_textMat.multmatrix(ogl_pmatrix);
  ogl_textMat.multmatrix(ogl_mvmatrix);
  
  float fEyeDir[3] = {0.f,0.f,-1.f};
 // float fEyePos[3] = {0.f, 0.f, 0.f};
 // float fEyeUp[3] = {0.0, 1.0, 0.0};	//todo replace w/ actual values..
  //fEyePos[0] = ogl_mvmatrix[12];
  //fEyePos[1] = ogl_mvmatrix[13];
  //fEyePos[2] = ogl_mvmatrix[14];
  //fEyeDir[0] = ogl_mvmatrix[8];
  //fEyeDir[1] = ogl_mvmatrix[9];
  //fEyeDir[2] = ogl_mvmatrix[10];
  
  /*fEyeDir[0] = ogl_mvmatrix[2];
  fEyeDir[1] = ogl_mvmatrix[6];
  fEyeDir[2] = ogl_mvmatrix[10];
  jvec3 vED(fEyeDir[0], fEyeDir[1], fEyeDir[2]);
  vED = vED.normalize();
  fEyeDir[0] = vED.x;
  fEyeDir[1] = vED.y;
  fEyeDir[2] = vED.z;*/

  jvec3 viewDir = fionaConf.headRot.rot(-ZAXIS);
  viewDir = fionaConf.camRot.rot(viewDir);
  viewDir = viewDir.normalize();
  fEyeDir[0] = viewDir.x;
  fEyeDir[1] = viewDir.y;
  fEyeDir[2] = viewDir.z;

  //ogl_lightpos[0][0] = viewDir.x;
  //ogl_lightpos[0][1] = viewDir.y;
  //ogl_lightpos[0][2] = viewDir.z;

  OpenGLRenderer::set_eye_dir(fEyeDir);
  /*OpenGLRenderer::set_eye_pos(fEyePos);
  OpenGLRenderer::set_eye_up(fEyeUp);*/

  // call OpenGLRenderer to do the rest of the rendering the normal way
  OpenGLRenderer::render(cmdlist);
 // glPopMatrix();
}

// update after drawing
void FionaVMDDisplayDevice::update(int do_update) {

	if(ogl_useglslshader)
	{
		glDepthMask(GL_TRUE);
		glDepthFunc(GL_LESS);
	}
}

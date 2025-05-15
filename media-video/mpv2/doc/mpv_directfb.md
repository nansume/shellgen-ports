 MPV with support DirectFB
 =========================

Support directfb in mpv through SDL2.

Build:
---------------------------------
mpv
  --enable-sdl             enable SDL audio output [disable]
  --enable-sdl2            enable SDL 2.0+ audio and video output [disable]
---------------------------------------------------------------------------
sdl2
  --enable-video-directfb        use DirectFB video driver [[default=no]]
---------------------------------------------------------------------------

===================================================
 SDL on DirectFB
---------------------------------------------------
 Supports:
---------------------------------------------------
 - Hardware YUV overlays
 - OpenGL - software only
 - 2D/3D accelerations (depends on directfb driver)
 - multiple displays
 - windows
===================================================


What you need:
* DirectFB 1.0.1 - 1.7.7
* Kernel-Framebuffer support: required: vesafb, radeonfb, simplefb, radeon[drm], ...
* Mesa 7.0.x         - optional for OpenGL

+++++++++++++++++++++++++++++++++++++++++++++++++++++

/etc/directfbrc
-----------------------------------------------------
 This file should contain the following lines to make
 your joystick work and avoid crashes:
 ------------------------
 disable-module=joystick
 disable-module=cle266
 disable-module=cyber5k
 no-linux-input-grab
 ------------------------

To disable to use x11 backend when DISPLAY variable is found use:
-----------------------------------------------------------------
export SDL_DIRECTFB_X11_CHECK=0
-----------------------------------------------------------------

To disable the use of linux input devices, i.e. multimice/multikeyboard support, use:
-------------------------------------------------------------------------------------
export SDL_DIRECTFB_YUV_DIRECT=1
-------------------------------------------------------------------------------------
 This is disabled by default. It will only support one
 YUV texture, namely the first. Every other YUV texture will be
 rendered in software.

In addition, you may use (directfb-1.2.x - directfb-1.7.7):
-----------------------------------------------------------
export SDL_DIRECTFB_YUV_UNDERLAY=1
-----------------------------------------------------------
 to make the YUV texture an underlay. This will make the cursor to
 be shown.

==================================================================================================

 Simple Window Manager
 =====================

 The driver has support for a very, very basic window manager you may
 want to use when running with "wm=default". Use

 export SDL_DIRECTFB_WM=1

 to enable basic window borders. In order to have the window title rendered,
 you need to have the following font installed:

 /usr/share/fonts/truetype/freefont/FreeSans.ttf

 OpenGL Support
 ==============

 The following instructions will give you *software* OpenGL. However this
 works at least on all directfb supported platforms.

--------------------------------------------------------------------------

 As of this writing 20100802 you need to pull Mesa from git and do the following:

 ------------------------
 git clone git://anongit.freedesktop.org/git/mesa/mesa
 cd mesa
 git checkout 2c9fdaf7292423c157fc79b5ce43f0f199dd753a
 ------------------------

 Edit configs/linux-directfb so that the Directories-section looks like
 ------------------------
 # Directories
 SRC_DIRS     = mesa glu
 GLU_DIRS     = sgi
 DRIVER_DIRS  = directfb
 PROGRAM_DIRS =
 ------------------------

 make linux-directfb
 make

 echo Installing - please enter sudo pw.

 sudo make install INSTALL_DIR=/usr/local/dfb_GL
 cd src/mesa/drivers/directfb
 make
 sudo make install INSTALL_DIR=/usr/local/dfb_GL
 ------------------------

 To run the SDL - testprograms:

 export SDL_VIDEODRIVER=directfb
 export LD_LIBRARY_PATH=/usr/local/dfb_GL/lib
 export LD_PRELOAD=/usr/local/dfb_GL/libGL.so.7

 ./testgl

==================================================================================================
[Getting mpv player to work in the framebuffer](https://bbs.archlinux.org/viewtopic.php?id=176072)
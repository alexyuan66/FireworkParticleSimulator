module graphics_window;

import std.string;

import platform;
import bindbc.sdl;
import bindbc.opengl;

/// Abstraction for creating a Hardware Accelerated Graphics Window
class GraphicsWindow{
		SDL_Window* mWindow;

		~this(){
				// Destroy our window
				SDL_DestroyWindow(mWindow);
		}
}

/// Implementation of an OpenGL Window
class OpenGLWindow : GraphicsWindow{
		SDL_GLContext mContext;
		/// Setup OpenGL and any libraries
		this(string title, int major_ogl_version, int minor_ogl_version){
				// Setup SDL OpenGL Version
				SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, major_ogl_version );
				SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, minor_ogl_version );
				SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );
				// We want to request a double buffer for smooth updating.
				SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
				SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

				// Create an application window using OpenGL that supports SDL
				mWindow = SDL_CreateWindow(title.toStringz , SDL_WINDOWPOS_UNDEFINED,SDL_WINDOWPOS_UNDEFINED, 640, 480,SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN );

				// Create the OpenGL context and associate it with our window
				mContext = SDL_GL_CreateContext(mWindow);

				// Load OpenGL Function calls
				auto retVal = LoadOpenGLLib();

				// Check OpenGL version
				GetOpenGLVersionInfo();
		}
	
		/// Destructor
		~this(){
				// Destroy our context
				SDL_GL_DeleteContext(mContext);
		}
}

/// Implementation of a Vulkan  Window
class VulkanWindow : GraphicsWindow{
		this(string title){
				assert(0,"Vulkan is not yet supported");
		}
	
		/// Destructor
		~this(){
		}
}

module rendertarget;

import std.stdio;

import bindbc.sdl;
import bindbc.opengl;

import texture,pipeline,geometry,renderer;

/// A render target is an abstration for a framebuffer object
class RenderTarget{
    GLuint mRenderTargetHandle;
		Texture mTexture; 
    uint mWidth;
    uint mHeight;
    uint mWindowWidth;
    uint mWindowHeight;

    this(uint width, uint height, uint windowWidth, uint windowHeight){
        // TODO: May want to consider some assertion if the width an height of the framebuffer are not
        //       the same a a window. We could otherwise 'stretch' the framebuffer to fit if we needed.
        mWidth = width;
        mHeight = height;
        mWindowWidth = windowWidth;
        mWindowHeight = windowHeight;

        // Generate a framebuffer
        glGenFramebuffers(1, &mRenderTargetHandle);
        glBindFramebuffer(GL_FRAMEBUFFER,mRenderTargetHandle);

        // Create a Texture that we'll draw to
				mTexture = new Texture(width,height,true);
        // NOTE: Verify that it is important to use a poor filtering method so we get the exact values back
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        // Configure framebuffer
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D, mTexture.GetTextureID(), 0);

        // Optional Depth Buffer
        GLuint depthrenderbuffer;
        glGenRenderbuffers(1, &depthrenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthrenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, width, height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, depthrenderbuffer);


        // Set the list of draw buffers
//        const GLenum[1] DrawBuffers = [GL_COLOR_ATTACHMENT0];
//        glDrawBuffers(1, DrawBuffers.ptr);

        // Almost always a good idea to check framebuffer status
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
						writeln("glGetError: ",glGetError());
            assert(0,"error with glframebuffer not being complete!");
        }

        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

	// Select the current framebuffer
    void Bind(){
        glBindFramebuffer(GL_FRAMEBUFFER, mRenderTargetHandle);
        glViewport(0,0,mWidth, mHeight);
        // glClearColor(0, 0, 0, 1);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    void Unbind(){
      glBindFramebuffer(GL_FRAMEBUFFER, 0);
      glViewport(0, 0, mWindowWidth, mWindowHeight);
    }

    Texture getTexture(){
        return mTexture;
    }
}


/// After rendering our scene, we use this to do any post processing
/// When using multiple render targets
class PostRenderDraw{

		Pipeline mScreenPipeline;
		SurfaceTexturedTriangle mQuad;

		/// Pass in the renderer, and we can grab the render target
		/// from the renderer
		this(string pipelineName, string pipelinePath){
				/// TODO put in these arguments
				mScreenPipeline = new Pipeline(pipelineName,pipelinePath);
				mQuad = MakeTexturedQuad();
		}	

		/// TODO update the 'screen' parameter to the pipelineName that
		/// we are otherwise using.
		/// Takes in the renderer that is captured with its render target, and
		/// we then are able to run a post processing function
		void PostRender(Renderer r){	
				assert(r !is null, "Cannot have null renderer for post processing");
				// Draw the default framebuffer
				glBindFramebuffer(GL_FRAMEBUFFER, 0);
				glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

				PipelineUse(mScreenPipeline.mPipelineName);
				glBindTexture(GL_TEXTURE_2D,r.mRenderTarget.mTexture.GetTextureID());
				glActiveTexture(GL_TEXTURE0);
				glUniform1i(glGetUniformLocation(mScreenPipeline.mProgramObjectID,"sampler1"),0);        
				mQuad.Render();	
		}
}

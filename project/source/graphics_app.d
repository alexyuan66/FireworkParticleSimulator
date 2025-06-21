/// The main graphics application with the main graphics loop.
module graphics_app;
import std.stdio;
import core;
import mesh, linear, scene, materials, geometry, rendertarget, graphics_window, particles;
import platform;

import bindbc.sdl;
import bindbc.opengl;

import std.math;

/// The main graphics application.
struct GraphicsApp{
		bool mGameIsRunning		= true;
		bool mRenderWireframe = false;
		
		// Window for the graphics application
		GraphicsWindow mWindow;
		// Scene
		SceneTree mSceneTree;
		// Camera
		Camera mCamera;
		// Renderer
		Renderer mRenderer;	
		// Note: For future, you can use for post rendering effects on the renderer
    //		PostRenderDraw mPostRenderer;

		// Firework
		Launcher launcher;
		float lastTime;

		// Water
		RenderTarget refractionRT;
		RenderTarget reflectionRT;
		float waterTime;
		float waterY;
		float clipPlaneValue;

		/// Setup OpenGL and any libraries
		this(string title, int major_ogl_version, int minor_ogl_version){
				// Create a window
				mWindow = new OpenGLWindow(title, major_ogl_version, minor_ogl_version);
				// Create a renderer
        // NOTE: For now, our renderer will draw into the default renderbuffer (so 'null' for final pamater.
				mRenderer = new Renderer(mWindow,640,480, null);
        // NOTE: In future, you can create a custom render target to draw to as follows.
				//       mRenderer = new Renderer(mWindow,640,480, new RenderTarget(640,480));
				// Handle effects for the renderer
        // mPostRenderer = new PostRenderDraw("screen","./pipelines/screen/"); 

				// Create a camera
				mCamera = new Camera();
				// Create (or load) a Scene Tree
				mSceneTree = new SceneTree("root");
				// Fireworks
				lastTime  = SDL_GetTicks() / 1000f;
				// Water
				refractionRT = new RenderTarget(640 / 2, 480 / 2, 640, 480);
				reflectionRT = new RenderTarget(640 / 2, 480 / 2, 640, 480);
				waterTime = 0.0f;
				waterY = -11.0f;
				clipPlaneValue = -9.5f;
		}

		/// Destructor
		~this(){
		}

		/// Handle input
		void Input(){
				// Store an SDL Event
				SDL_Event event;
				while(SDL_PollEvent(&event)){
						if(event.type == SDL_QUIT){
								writeln("Exit event triggered (probably clicked 'x' at top of the window)");
								mGameIsRunning= false;
						}
						if(event.type == SDL_KEYDOWN){
								if(event.key.keysym.scancode == SDL_SCANCODE_ESCAPE){
										writeln("Pressed escape key and now exiting...");
										mGameIsRunning= false;
								}else if(event.key.keysym.sym == SDLK_TAB){
										mRenderWireframe = !mRenderWireframe;
								}
								else if(event.key.keysym.sym == SDLK_DOWN){
										mCamera.MoveBackward();
								}
								else if(event.key.keysym.sym == SDLK_UP){
										mCamera.MoveForward();
								}
								else if(event.key.keysym.sym == SDLK_LEFT){
										mCamera.MoveLeft();
								}
								else if(event.key.keysym.sym == SDLK_RIGHT){
										mCamera.MoveRight();
								}
								else if(event.key.keysym.sym == SDLK_a){
										mCamera.MoveUp();
								}
								else if(event.key.keysym.sym == SDLK_z){
										mCamera.MoveDown();
								}
								else if(event.key.keysym.scancode == SDL_SCANCODE_SPACE){
									launcher.launchParticle();
								}
								writeln("Camera Position: ",mCamera.mEyePosition);
						}
				}

				// Retrieve the mouse position
				int mouseX,mouseY;
				SDL_GetMouseState(&mouseX,&mouseY);
				mCamera.MouseLook(mouseX,mouseY);
		}

		/// A helper function to setup a scene.
		/// NOTE: In the future this can use a configuration file to otherwise make our graphics applications
		///       data-driven.
		void SetupScene(){
				// Skybox
				string[6] faces = [
						"./assets/right.ppm",
						"./assets/left.ppm",
						"./assets/top.ppm",
						"./assets/bottom.ppm",
						"./assets/front.ppm",
						"./assets/back.ppm"];
				Pipeline skyPipeline = new Pipeline("textureSkybox", "./pipelines/skybox/");
				IMaterial skyMaterial = new TextureSkyboxMaterial("textureSkybox", faces);
				skyMaterial.AddUniform(new Uniform("uView",       "mat4", mCamera.mViewMatrix.DataPtr()));
				skyMaterial.AddUniform(new Uniform("uProjection", "mat4", mCamera.mProjectionMatrix.DataPtr()));
				skyMaterial.AddUniform(new Uniform("skybox",      0));
				float[] skyVerts = [
					// back face
					-1,  1, -1,  -1, -1, -1,   1, -1, -1,
					1, -1, -1,   1,  1, -1,  -1,  1, -1,
					// front face
					-1, -1,  1,  -1,  1,  1,   1,  1,  1,
					1,  1,  1,   1, -1,  1,  -1, -1,  1,
					// left face
					-1,  1,  1,  -1,  1, -1,  -1, -1, -1,
					-1, -1, -1,  -1, -1,  1,  -1,  1,  1,
					// right face
					1,  1, -1,   1,  1,  1,   1, -1,  1,
					1, -1,  1,   1, -1, -1,   1,  1, -1,
					// top face
					-1,  1,  1,   1,  1,  1,   1,  1, -1,
					1,  1, -1,  -1,  1, -1,  -1,  1,  1,
					// bottom face
					-1, -1, -1,   1, -1, -1,   1, -1,  1,
					1, -1,  1,  -1, -1,  1,  -1, -1, -1];
				ISurface skybox = new SurfaceSkybox(skyVerts);
				MeshNode m = new MeshNode("skybox", skybox, skyMaterial);
				mSceneTree.GetRootNode().AddChildSceneNode(m);

				// Create terrain
				Pipeline multitexturePipeline = new Pipeline("multitexturePipeline","./pipelines/multitexture/");
				IMaterial multitextureMaterial = new MultiTextureMaterial("multitexturePipeline", "./assets/sand.ppm", "./assets/dirt.ppm", "./assets/grass.ppm");
				multitextureMaterial.AddUniform(new Uniform("sampler1", 0));
				multitextureMaterial.AddUniform(new Uniform("sampler2", 0));
				multitextureMaterial.AddUniform(new Uniform("sampler3", 0));
				multitextureMaterial.AddUniform(new Uniform("uModel", "mat4", null));
				multitextureMaterial.AddUniform(new Uniform("uView", "mat4", mCamera.mViewMatrix.DataPtr()));
				multitextureMaterial.AddUniform(new Uniform("uProjection", "mat4", mCamera.mProjectionMatrix.DataPtr()));
				multitextureMaterial.AddUniform(new Uniform("uClipPlane", clipPlaneValue));
				multitextureMaterial.AddUniform(new Uniform("uClipSign", 1.0f));
				ISurface terrainSurface = new SurfaceTerrainPerlin(400, 400);
				MeshNode  m2        				= new MeshNode("terrain",terrainSurface, multitextureMaterial);
				m2.mModelMatrix = MatrixMakeTranslation(vec3(0, -5.0f, 0));
				mSceneTree.GetRootNode().AddChildSceneNode(m2);

				// Water
				Pipeline waterPipeline = new Pipeline("waterPipeline","./pipelines/water/");
				WaterMaterial waterMaterial = new WaterMaterial("waterPipeline", reflectionRT.getTexture(), refractionRT.getTexture(), "./assets/waterDUDV.ppm", "./assets/waterNormalMap.ppm");
				waterMaterial.AddUniform(new Uniform("uModel", "mat4", null));
				waterMaterial.AddUniform(new Uniform("uView", "mat4", mCamera.mViewMatrix.DataPtr()));
				waterMaterial.AddUniform(new Uniform("uProjection", "mat4", mCamera.mProjectionMatrix.DataPtr()));
				waterMaterial.AddUniform(new Uniform("uTime", waterTime));
				waterMaterial.AddUniform(new Uniform("reflectionTex", 0));
				waterMaterial.AddUniform(new Uniform("refractionTex", 1));
				waterMaterial.AddUniform(new Uniform("dudvMap", 2));
				SurfaceWater waterSurface = new SurfaceWater(132, 132, 132.0f, 132.0f);
				MeshNode m3 = new MeshNode("water", waterSurface, waterMaterial);
				m3.mModelMatrix = MatrixMakeTranslation(vec3(0, waterY + 4.25, 0));
				mSceneTree.GetRootNode().AddChildSceneNode(m3);

				// Fireworks
				launcher = new Launcher(1000);
				Pipeline particlePipeline = new Pipeline("particlePipeline", "./pipelines/particle/");
				ParticleMaterial particleMaterial = new ParticleMaterial("particlePipeline", "./assets/circle3.ppm");
				particleMaterial.AddUniform(new Uniform("uView","mat4", mCamera.mViewMatrix.DataPtr()));
				particleMaterial.AddUniform(new Uniform("uProjection","mat4", mCamera.mProjectionMatrix.DataPtr()));
				particleMaterial.AddUniform(new Uniform("uTex", 0));
				SurfaceFirework fireworkSurface = new SurfaceFirework(launcher);
				MeshNode fwNode = new MeshNode("firework", fireworkSurface, particleMaterial);
				mSceneTree.GetRootNode().AddChildSceneNode(fwNode);
		}

		/// Update gamestate
		void Update(){
				// Update fireworks
				float now = SDL_GetTicks() / 1000f;
				float dt  = now - lastTime;
				lastTime  = now;
				launcher.update(dt, mCamera.mEyePosition);

				// Update water
				waterTime += dt;
				MeshNode water = cast(MeshNode)mSceneTree.FindNode("water");
				water.mMaterial.AddUniform(new Uniform("uTime", waterTime));

		}

		void setClipPlane(float sign)
		{
			auto terrain = cast(MeshNode)mSceneTree.FindNode("terrain");
			terrain.mMaterial.AddUniform(new Uniform("uClipSign", sign));
		}

		/// Render our scene by traversing the scene tree from a specific viewpoint
		void Render(){
				if(mRenderWireframe){
						glPolygonMode(GL_FRONT_AND_BACK,GL_LINE); 
				}else{
						glPolygonMode(GL_FRONT_AND_BACK,GL_FILL); 
				}
				
				// Hide water for refraction and reflection passes
				auto waterNode = cast(MeshNode)mSceneTree.FindNode("water");
				waterNode.mVisible = false;
				auto realEye   = mCamera.mEyePosition;
				auto realYaw   = mCamera.yaw;
				auto realPitch = mCamera.pitch;

				// REFLECTION PASS
				// Flip camera across waterY
				float dy = mCamera.mEyePosition.y - waterY;
				mCamera.mEyePosition.y -= 0.1*dy;
				mCamera.pitch = -realPitch;
				mCamera.UpdateViewMatrix();
				setClipPlane(1.0f);
				glEnable(GL_CLIP_DISTANCE0);
				reflectionRT.Bind();
				mSceneTree.SetCamera(mCamera);
				mSceneTree.StartTraversal();
				reflectionRT.Unbind();
				glDisable(GL_CLIP_DISTANCE0);

				// Restore camera
				mCamera.mEyePosition = realEye;
				mCamera.yaw           = realYaw;
				mCamera.pitch         = realPitch;
				mCamera.UpdateViewMatrix();

				// REFRACTION PASS
				setClipPlane(-1.0f);
				glEnable(GL_CLIP_DISTANCE0);
				refractionRT.Bind();
				mSceneTree.SetCamera(mCamera);
				mSceneTree.StartTraversal();
				refractionRT.Unbind();
				glDisable(GL_CLIP_DISTANCE0);

				// Draw the whole scene with everything + reflection and refraction
				waterNode.mVisible = true;
				mRenderer.Render(mSceneTree, mCamera);
		}

		/// Process 1 frame
		void AdvanceFrame(){
				Input();
				Update();
				Render();

				SDL_Delay(16);	// NOTE: This is a simple way to cap framerate at 60 FPS,
												// 		   you might be inclined to improve things a bit.
		}

		/// Main application loop
		void Loop(){
				// Setup the graphics scene
				SetupScene();

				// Lock mouse to center of screen
				// This will help us get a continuous rotation.
				// NOTE: On occasion folks on virtual machine or WSL may not have this work,
				//       so you'll have to compute the 'diff' and reposition the mouse yourself.
				SDL_WarpMouseInWindow(mWindow.mWindow,640/2,320/2);

				// Run the graphics application loop
				while(mGameIsRunning){
						AdvanceFrame();
				}
		}
}


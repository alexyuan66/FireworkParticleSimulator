/// Provides the base calss for any derived materials
module material;

import uniform, linear, pipeline, mesh;
import bindbc.opengl;

/// A Material consists of the shader and all of the uniform variables
/// needed to otherwise utilze that material
class IMaterial{
    string mPipelineName;
    GLuint mProgramObjectID;

    /// Map of uniforms for the material
    Uniform[string] mUniformMap;

    /// Disable the default constructor
    @disable this();

    /// Default constructor for an IMaterial.
    /// Generally it is expected that any derived classes
    /// will call this (using 'super') in order to setup a material properly.
    this(string pipelineName){
        // First check if we have a valid pipeline
        PipelineCheckValidName(pipelineName);	

        // Associate material with pipeline
        mPipelineName = pipelineName;
        mProgramObjectID = Pipeline.sPipeline[pipelineName];

				// Add common uniforms to all materials.
				// The 4th parameter is set to the pointer where the value will be updated each frame later on.
				// AddUniform(new Uniform("uModel", "mat4", null));
				AddUniform(new Uniform("uView", "mat4", null));
				AddUniform(new Uniform("uProjection", "mat4", null));
    }

    /// Add a new uniform to our materials
    void AddUniform(Uniform u){
        // Assign the pipeline id of this uniform automatically
        u.mPipelineId     = Pipeline.sPipeline[mPipelineName];
        // Check uniform name is valid, and then cache the location
        u.CheckAndCacheUniform(mPipelineName,u.mUniformName);
        // Add the uniform to the map of uniforms for the material
        mUniformMap[u.mUniformName] = u;
    }

    /// The update function should be overriden by any base classes
    /// The job of this function is to select the pipeline, and then
    /// to set any uniform values.
    void Update(){
        // Set our active Shader graphics pipeline 
        PipelineUse(mPipelineName);
    }
}


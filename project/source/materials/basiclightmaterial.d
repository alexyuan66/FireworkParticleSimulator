/// An example of a basic light material
module basiclightmaterial;

import pipeline, materials, uniform, linear;
import bindbc.opengl;

/// Represents a simple material
class BasicLightMaterial : IMaterial{
    /// Construct a new material 
    this(string pipelineName){
        /// delegate to the base constructor to do initialization
        super(pipelineName);

        /// Any additional code for setup after
				AddUniform(new Uniform("uLight1.color", "vec3", null));
				AddUniform(new Uniform("uLight1.position", "vec3", null));
    }
    /// BasicMaterial Update
    override void Update(){
        // Set our active Shader graphics pipeline 
        PipelineUse(mPipelineName);
    }
}

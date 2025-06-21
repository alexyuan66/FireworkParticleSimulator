// An example of a texture material
module textureskyboxmaterial;

import pipeline, materials, texture;
import bindbc.opengl;

/// Represents a simple material 
class TextureSkyboxMaterial : IMaterial{
    Texture cubeTex;

    /// Construct a new material for a pipeline, and load a texture for that pipeline
    this(string pipelineName, string[6] faces){
        /// delegate to the base constructor to do initialization
        super(pipelineName);
        cubeTex = loadCubemap(faces);
    }

    /// TextureMaterial.Update()
    override void Update(){
        // Set our active Shader graphics pipeline 
        PipelineUse(mPipelineName);

        // Set any uniforms for our mesh if they exist in the shader
        if("skybox" in mUniformMap){
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_CUBE_MAP, cubeTex.GetTextureID());
            mUniformMap["skybox"].Set(0);
        }
    }
}
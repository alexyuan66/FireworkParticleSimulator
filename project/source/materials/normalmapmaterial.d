// An example of a normal map material
module normalmapmaterial;

import pipeline, materials, texture, uniform;
import bindbc.opengl;

/// Represents a normal mapped material 
/// Some notes on 'albedo' vs 'diffuse map' for naming: https://www.a23d.co/blog/difference-between-albedo-and-diffuse-map
class NormalMapMaterial: IMaterial{
    Texture mTexture1;
    Texture mTexture2;

    /// Construct a new material for a pipeline, and load a texture for that pipeline
    this(string pipelineName, string textureFileName, string normalmapFileName){
        /// delegate to the base constructor to do initialization
        super(pipelineName);

        mTexture1 = new Texture(textureFileName);
        mTexture2 = new Texture(normalmapFileName);

        /// Any additional code for setup after
				AddUniform(new Uniform("albedomap",  0));
				AddUniform(new Uniform("normalmap",  0));
    }

    /// TextureMaterial.Update()
    override void Update(){
        // Set our active Shader graphics pipeline 
        PipelineUse(mPipelineName);

        // Set any uniforms for our mesh if they exist in the shader
        if("albedomap" in mUniformMap){
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D,mTexture1.mTextureID);
            mUniformMap["albedomap"].Set(0);
        }
        // Set any uniforms for our mesh if they exist in the shader
        if("normalmap" in mUniformMap){
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D,mTexture2.mTextureID);
            mUniformMap["normalmap"].Set(1);
        }
    }
}




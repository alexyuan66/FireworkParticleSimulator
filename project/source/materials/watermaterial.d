module watermaterial;

import core;
import pipeline, materials;
import bindbc.opengl;

/// Represents a simple material
class WaterMaterial : IMaterial{
    Texture reflection;
    Texture refraction;
    Texture dudv;
    Texture normal;

    /// Construct a new material 
    this(string pipelineName, Texture reflectionFBO, Texture refractionFBO, string dudvFile, string normalFile){
        /// delegate to the base constructor to do initialization
        super(pipelineName);

        /// Any additional code for setup after
        reflection = reflectionFBO;
        refraction = refractionFBO;
        dudv = new Texture(dudvFile);
        normal = new Texture(normalFile);
    }
    /// BasicMaterial Update
    override void Update(){
        // Set our active Shader graphics pipeline 
        PipelineUse(mPipelineName);

        if("reflectionTex" in mUniformMap){
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, reflection.mTextureID);
            mUniformMap["reflectionTex"].Set(0);
        }

        if("refractionTex" in mUniformMap){
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, refraction.mTextureID);
            mUniformMap["refractionTex"].Set(1);
        }

        if("dudvMap" in mUniformMap){
            glActiveTexture(GL_TEXTURE2);
            glBindTexture(GL_TEXTURE_2D, dudv.mTextureID);
            mUniformMap["dudvMap"].Set(2);
        }
    }
}

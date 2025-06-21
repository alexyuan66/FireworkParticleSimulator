module particlematerial;

import bindbc.opengl;
import pipeline;
import materials;
import texture;

class ParticleMaterial : IMaterial {
    Texture texture;

    this(string pipelineName, string path) {
        super(pipelineName);
        texture = new Texture(path);
    }

    override void Update() {
        PipelineUse(mPipelineName);
        // bind circle sampler
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture.GetTextureID());
        mUniformMap["uTex"].Set(0);
    }
}
/// Create a triangle strip for terrain
module skyboxgeometry;

import bindbc.opengl;
import std.stdio;
import geometry;
import core;
import error;

class SurfaceSkybox : ISurface {
    GLuint mVBO;
    size_t mVertices;

    this(GLfloat[] verts) {
        mVertices = verts.length / 3;

        // VAO
        glGenVertexArrays(1, &mVAO);
        glBindVertexArray(mVAO);

        // VBO
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, verts.length * GLfloat.sizeof, verts.ptr, GL_STATIC_DRAW);

        // attribute 0 = vec3 position
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * GLfloat.sizeof, cast(void*)0);

        // cleanup
        glBindVertexArray(0);
        glDisableVertexAttribArray(0);
    }

    override void Render() {
        glDisable(GL_DEPTH_TEST);
        glDepthMask(GL_FALSE);
        glDepthFunc(GL_LEQUAL);
        glBindVertexArray(mVAO);
        glDrawArrays(GL_TRIANGLES, 0, cast(int)mVertices);
        glEnable(GL_DEPTH_TEST);
        glDepthMask(GL_TRUE);
        glDepthFunc(GL_LESS);
    }
}



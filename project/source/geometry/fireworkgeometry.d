module fireworkgeometry;

import bindbc.opengl;
import core;
import geometry;
import particles;

import std.stdio;

class SurfaceFirework : ISurface {
    GLuint  mVAO;
    GLuint  mVBO_quad;
    GLuint  mVBO_posSize;
    GLuint  mVBO_color;
    size_t  mMaxCount;
    Launcher launcher;

    this(Launcher launcher) {
        this.launcher  = launcher;
        this.mMaxCount = launcher.particles.length;

        float[] quad = [
            -0.5f,-0.5f,
             0.5f,-0.5f,
            -0.5f, 0.5f,
             0.5f, 0.5f
        ];

        glGenVertexArrays(1, &mVAO);
        glBindVertexArray(mVAO);

        // Quad corners
        glGenBuffers(1, &mVBO_quad);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO_quad);
        glBufferData(GL_ARRAY_BUFFER, quad.length * float.sizeof, quad.ptr, GL_STATIC_DRAW);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, cast(void*)0);

        // Pos + Size instanced
        glGenBuffers(1, &mVBO_posSize);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO_posSize);
        glBufferData(GL_ARRAY_BUFFER, mMaxCount * 4 * float.sizeof, null, GL_STREAM_DRAW);
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, 4*float.sizeof, cast(void*)0);
        glVertexAttribDivisor(1, 1);

        // Color instanced
        glGenBuffers(1, &mVBO_color);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO_color);
        glBufferData(GL_ARRAY_BUFFER, mMaxCount * 4 * float.sizeof, null, GL_STREAM_DRAW);
        glEnableVertexAttribArray(2);
        glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, 4*float.sizeof, cast(void*)0);
        glVertexAttribDivisor(2, 1);

        glBindVertexArray(0);
    }

    override void Render() {
        glEnable(GL_BLEND);
		// glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        // Upload the pos + size array via glBufferSubData to instanced VBOs
        auto count = cast(GLsizei) launcher.liveCount;
        glBindBuffer(GL_ARRAY_BUFFER, mVBO_posSize);
        glBufferData(
            GL_ARRAY_BUFFER,
            mMaxCount * 4 * float.sizeof,
            null,
            GL_STREAM_DRAW);
        glBufferSubData(GL_ARRAY_BUFFER, 0, count*4*float.sizeof, launcher.particlePosSize.ptr);

        // Upload the color array via glBufferSubData to instanced VBOs
        glBindBuffer(GL_ARRAY_BUFFER, mVBO_color);
        glBufferData(
            GL_ARRAY_BUFFER,
            mMaxCount * 4 * float.sizeof,
            null,
            GL_STREAM_DRAW);
        glBufferSubData(GL_ARRAY_BUFFER, 0, count*4*float.sizeof, launcher.particleColor.ptr);

        // VAO
        glBindVertexArray(mVAO);
        glDrawArraysInstanced(GL_TRIANGLE_STRIP, 0, 4, count);
        glBindVertexArray(0);
        glDisable(GL_BLEND);
    }
}

// Debug geometry -> not being used
class SurfaceFireworkDebugQuad : ISurface {
    GLuint mVAO;
    GLuint mVBO;

    this() {
        float[] quad = [
            //  X     Y     Z
            -0.5f, -0.5f, 0.0f,
             0.5f, -0.5f, 0.0f,
            -0.5f,  0.5f, 0.0f,
             0.5f,  0.5f, 0.0f
        ];

        glGenVertexArrays(1, &mVAO);
        glBindVertexArray(mVAO);

        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, quad.length * float.sizeof, quad.ptr, GL_STATIC_DRAW);

        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0);

        glBindVertexArray(0);
    }

    override void Render() {
        glBindVertexArray(mVAO);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glBindVertexArray(0);
    }
}

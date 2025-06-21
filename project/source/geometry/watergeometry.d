module watergeometry;

import bindbc.opengl;
import linear;
import geometry;

class SurfaceWater : ISurface {
    GLuint mVAO;
    GLuint mVBO;
    GLuint mIBO;
    GLsizei indexCount;
    uint mVertsX;
    uint mRows;

    this(uint xCount, uint zCount, float sizeX, float sizeZ) {
        mVertsX = xCount + 1;
        mRows   = zCount;
        VertexFormat3F2F[] verts;
        uint[] idx;
        verts.reserve((xCount + 1) * (zCount + 1));
        idx.reserve(zCount * 2 * mVertsX);

        // Get position + uv
        foreach(z; 0 .. zCount + 1) {
            float wz = (cast(float)z / zCount - 0.5f) * sizeZ;
            foreach(x; 0 .. xCount + 1) {
                float wx = (cast(float)x / xCount - 0.5f) * sizeX;
                float u  = x / cast(float)xCount;
                float v  = z / cast(float)zCount;
                verts ~= VertexFormat3F2F([wx, 0.0f, wz], [u, v]);
            }
        }

        // Get indexes
        foreach(row; 0 .. zCount) {
            uint base = row * mVertsX;
            foreach(col; 0 .. mVertsX) {
                idx ~= base + col;
                idx ~= base + col + mVertsX;
            }
        }

        // VAO
        glGenVertexArrays(1, &mVAO);
        glBindVertexArray(mVAO);

        // VBO
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, verts.length * VertexFormat3F2F.sizeof, verts.ptr, GL_STATIC_DRAW);

        // Index buffer
        glGenBuffers(1, &mIBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, idx.length * uint.sizeof, idx.ptr, GL_STATIC_DRAW);

        SetVertexAttributes!VertexFormat3F2F();
        glBindVertexArray(0);
        DisableVertexAttributes!VertexFormat3F2F();
    }


    override void Render()
    {
        glBindVertexArray(mVAO);
        foreach(row; 0 .. mRows) {
            auto byteOffset = cast(void*)(row * 2 * mVertsX * uint.sizeof);
            glDrawElements(GL_TRIANGLE_STRIP, cast(GLsizei)(2 * mVertsX), GL_UNSIGNED_INT, byteOffset);
        }
        glBindVertexArray(0);
    }
}
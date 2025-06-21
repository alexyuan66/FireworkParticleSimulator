module terrainperlingeometry;

import bindbc.opengl;
import std.math;
import geometry;
import core;

class SurfaceTerrainPerlin : ISurface {
    GLuint              mVBO;
    GLuint              mIBO;
    VertexFormat3F2F[]  mVertices;
    uint[]              mIndices;
    uint                mXDimensions;
    uint                mZDimensions;
    size_t              mVerticesCount;
    size_t              mIndexCount;

    this(uint xDim, uint zDim) {
        mXDimensions = xDim;
        mZDimensions = zDim;
        MakeTerrain(xDim, zDim);
    }

    override void Render() {
        glBindVertexArray(mVAO);
        for (uint row = 0; row < mZDimensions - 1; ++row) {
            GLuint start = row * 2 * mXDimensions;
            GLuint count = 2 * mXDimensions;
            glDrawElements(GL_TRIANGLE_STRIP, cast(GLsizei)count, GL_UNSIGNED_INT, cast(void*)(start * GLuint.sizeof));
        }
        glBindVertexArray(0);
    }

    private void MakeTerrain(uint xDim, uint zDim) {
        mVertices.reserve(xDim * zDim);
        mIndices.reserve((zDim - 1) * 2 * xDim);

        // in your MakeTerrain(...) instead of a single sin/cos:
        float cellSize  = 1.0f;    // world units per grid cell
        float baseFreq  = 0.05f;   // starting frequency
        float baseAmp   = 12.0f;    // starting amplitude
        float tileCount = 20.0f;   // UV tiling

        // octave parameters
        enum int OCTAVES = 4;
        float freq = baseFreq;
        float amp  = baseAmp;

        foreach (z; 0 .. zDim) {
            foreach (x; 0 .. xDim) {
                float wx = (cast(float)x - (xDim-1)/2f) * cellSize;
                float wz = (cast(float)z - (zDim-1)/2f) * cellSize;

                // build a fractal sum of sine / cosine “noise”
                float h = 0.0f;
                freq = baseFreq;
                amp  = baseAmp;
                foreach(o; 0 .. OCTAVES) {
                    h += sin(wx * freq + o * 13.37f) * amp;
                    h += cos(wz * freq + o * 42.0f)  * amp;
                    freq *= 2.0f;   // double frequency each octave
                    amp  *= 0.5f;   // half the amplitude each octave
                }

                float u = cast(float)x / (xDim-1) * tileCount;
                float v = cast(float)z / (zDim-1) * tileCount;
                mVertices ~= VertexFormat3F2F([wx, h, wz], [u, v]);
            }
        }
        mVerticesCount = mVertices.length;

        for (uint row = 0; row < zDim-1; ++row) {
            foreach (col; 0 .. xDim) {
                mIndices ~= row*xDim + col;
                mIndices ~= (row+1)*xDim + col;
            }
        }
        mIndexCount = mIndices.length;

        // Upload to GPU
        glGenVertexArrays(1, &mVAO);
        glBindVertexArray(mVAO);

        // IBO
        glGenBuffers(1, &mIBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                     mIndexCount * uint.sizeof,
                     mIndices.ptr,
                     GL_STATIC_DRAW);

        // VBO
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER,
                     mVerticesCount * VertexFormat3F2F.sizeof,
                     mVertices.ptr,
                     GL_STATIC_DRAW);

        // tell GL about position (location=0) and texcoord (location=1)
        SetVertexAttributes!VertexFormat3F2F();

        // unbind
        glBindVertexArray(0);
        DisableVertexAttributes!VertexFormat3F2F();
    }
}
/// Triangle Creation
module trianglegeometry;

import bindbc.opengl;
import std.stdio;
import geometry;
import linear;
import error;

/// Geometry stores all of the vertices and/or indices for a 3D object.
/// Geometry also has the responsibility of setting up the 'attributes'
class SurfaceTriangle: ISurface{
    GLuint mVBO;
    size_t mTriangles;

    /// Geometry data
    this(GLfloat[] vbo){
        MakeTriangleFactory(vbo);
    }

    /// Render our geometry
    override void Render(){
        // Bind to our geometry that we want to draw
        glBindVertexArray(mVAO);
        // Call our draw call
        glDrawArrays(GL_TRIANGLES,0,cast(int) mTriangles);
    }

    /// Setup MeshNode as a Triangle
    void MakeTriangleFactory(GLfloat[] vbo){
        // Compute the number of traingles.
        // Note: 6 floats per vertex, is why we are dividing by 6
        mTriangles = vbo.length / 6;

        // Vertex Arrays Object (VAO) Setup
        glGenVertexArrays(1, &mVAO);
        // We bind (i.e. select) to the Vertex Array Object (VAO) that we want to work withn.
        glBindVertexArray(mVAO);

        // Vertex Buffer Object (VBO) creation
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, vbo.length* GLfloat.sizeof, vbo.ptr, GL_STATIC_DRAW);

        // Function call to setup attributes
        SetVertexAttributes!VertexFormat3F3F();

        // Unbind our currently bound Vertex Array Object
        glBindVertexArray(0);

        // Turn off attributes
        DisableVertexAttributes!VertexFormat3F3F();
    }
}

/// Stores triangles that also have texture coordinates
class SurfaceTexturedTriangle: ISurface{
    GLuint mVBO;
    size_t mTriangles;

    /// Geometry data
    this(GLfloat[] vbo){
        MakeTriangleFactory(vbo);
    }

    /// Render our geometry
    override void Render(){
        // Bind to our geometry that we want to draw
        glBindVertexArray(mVAO);
        // Call our draw call
        glDrawArrays(GL_TRIANGLES,0,cast(int) mTriangles);
    }

    /// Setup MeshNode as a Triangle
    void MakeTriangleFactory(GLfloat[] vbo){

        // Compute the number of traingles.
        // Note: 5 floats per vertex, is why we are dividing by 5
        mTriangles = vbo.length / 5;

        // Vertex Arrays Object (VAO) Setup
        glGenVertexArrays(1, &mVAO);
        // We bind (i.e. select) to the Vertex Array Object (VAO) that we want to work withn.
        glBindVertexArray(mVAO);

        // Vertex Buffer Object (VBO) creation
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, vbo.length* GLfloat.sizeof, vbo.ptr, GL_STATIC_DRAW);

        // Function call to setup attributes
        SetVertexAttributes!VertexFormat3F2F();

        // Unbind our currently bound Vertex Array Object
        glBindVertexArray(0);

        // Turn off attributes
        DisableVertexAttributes!VertexFormat3F2F();
    }
}

/// Stores triangles that also have texture coordinates, normals, bitangents, and tangents
class SurfaceNormalMappedTriangle: ISurface{
    GLuint mVBO;
    size_t mTriangles;

    /// Geometry data
    this(GLfloat[] vbo){
        MakeTriangleFactory(vbo);
    }

    /// Render our geometry
    override void Render(){
        // Bind to our geometry that we want to draw
        glBindVertexArray(mVAO);
        // Call our draw call
        glDrawArrays(GL_TRIANGLES,0,cast(int) mTriangles);
    }

    /// Setup MeshNode as a Triangle
    void MakeTriangleFactory(GLfloat[] vbo){

        // Compute the number of traingles.
        // Note: 14 floats per vertex, is why we are dividing by 14
        mTriangles = vbo.length / 14;

        // Vertex Arrays Object (VAO) Setup
        glGenVertexArrays(1, &mVAO);
        // We bind (i.e. select) to the Vertex Array Object (VAO) that we want to work withn.
        glBindVertexArray(mVAO);

        // Vertex Buffer Object (VBO) creation
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, vbo.length* GLfloat.sizeof, vbo.ptr, GL_STATIC_DRAW);

        // Function call to setup attributes
        SetVertexAttributes!VertexFormat3F2F3F3F3F();

        // Unbind our currently bound Vertex Array Object
        glBindVertexArray(0);

        // Turn off attributes
        DisableVertexAttributes!VertexFormat3F2F();
    }
}


/// Helper function to return a textured quad
SurfaceTexturedTriangle MakeTexturedQuad(){
	return new SurfaceTexturedTriangle([
																				-1.0,1.0,0.0,  0.0,1.0,
																				-1.0,-1.0,0.0, 0.0,0.0,
																				1.0,-1.0,0.0,  1.0,0.0,
																				1.0,1.0,0.0, 1.0,1.0,
																				-1.0,1.0,0.0, 0.0,1.0,
																				1.0,-1.0,0.0, 1.0,0.0,
																		 ]
																		);
}


void SetTangentBitangent(GLfloat[] target, GLfloat[] otherVert1, GLfloat[] otherVert2)
{
    vec3 tangent;
    vec3 bitangent;

    // Positions
    vec3 pos1 = vec3(target[0], target[1], target[2]);
    vec3 pos2 = vec3(otherVert1[0], otherVert1[1], otherVert1[2]);
    vec3 pos3 = vec3(otherVert2[0], otherVert2[1], otherVert2[2]);

    // Texture coordinates
    vec2 uv1 = vec2(target[3], target[4]);
    vec2 uv2 = vec2(otherVert1[3], otherVert1[4]);
    vec2 uv3 = vec2(otherVert2[3], otherVert2[4]);

    // Get edges and delta UV
    vec3 edge1 = pos2 - pos1;
    vec3 edge2 = pos3 - pos1;
    vec2 deltaUV1 = uv2 - uv1;
    vec2 deltaUV2 = uv3 - uv1;

    // Calculate tangent and bitangent
    float f = 1.0f / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);
    tangent.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
    tangent.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
    tangent.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);

    bitangent.x = f * (-deltaUV2.x * edge1.x + deltaUV1.x * edge2.x);
    bitangent.y = f * (-deltaUV2.x * edge1.y + deltaUV1.x * edge2.y);
    bitangent.z = f * (-deltaUV2.x * edge1.z + deltaUV1.x * edge2.z);
    
    // Set values in target array
    target[$ - 6] = tangent.x;
    target[$ - 5] = tangent.y;
    target[$ - 4] = tangent.z;
    target[$ - 3] = bitangent.x;
    target[$ - 2] = bitangent.y;
    target[$ - 1] = bitangent.z;
}

/// Helper function to return a textured quad with normals, binormals, and bitangents
SurfaceNormalMappedTriangle MakeTexturedNormalMappedQuad(){
  //TODO: For students to compute binormal and bitangents (either here, or by writing a helper function -- your choice!)
  // Position, uv, normal, tangent (TODO), bitangent (TODO)
    
    // Initialize vertices
    GLfloat[] vert1_1 = cast(GLfloat[])[-1.0,1.0,0.0,  0.0,1.0,     0,0,-1.0, 0,0,0, 0,0,0];
    GLfloat[] vert2_1 = cast(GLfloat[])[-1.0,-1.0,0.0, 0.0,0.0,     0,0,-1.0, 0,0,0, 0,0,0];
    GLfloat[] vert3_1 = cast(GLfloat[])[1.0,-1.0,0.0,  1.0,0.0,     0,0,-1.0, 0,0,0, 0,0,0];
    GLfloat[] vert1_2 = cast(GLfloat[])[1.0,1.0,0.0,   1.0,1.0,     0,0,-1.0, 0,0,0, 0,0,0];
    GLfloat[] vert2_2 = cast(GLfloat[])[-1.0,1.0,0.0,  0.0,1.0,     0,0,-1.0, 0,0,0, 0,0,0];
    GLfloat[] vert3_2 = cast(GLfloat[])[1.0,-1.0,0.0,  1.0,0.0,     0,0,-1.0, 0,0,0, 0,0,0];

    // Set tangent bitangent value in each vertex
    SetTangentBitangent(vert1_1, vert2_1, vert3_1);
    SetTangentBitangent(vert2_1, vert1_1, vert3_1);
    SetTangentBitangent(vert3_1, vert2_1, vert1_1);
    SetTangentBitangent(vert1_2, vert2_2, vert3_2);
    SetTangentBitangent(vert2_2, vert1_2, vert3_2);
    SetTangentBitangent(vert3_2, vert2_2, vert1_2);

    // Append together
    GLfloat[] finalQuad = vert1_1 ~ vert2_1 ~ vert3_1 ~ vert1_2 ~ vert2_2 ~ vert3_2;
	return new SurfaceNormalMappedTriangle(finalQuad);
}

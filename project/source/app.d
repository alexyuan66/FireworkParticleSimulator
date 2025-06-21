import graphics_app;

/// Program entry point 
/// NOTE: When debugging, this is '_Dmain'
void main(string[] args)
{
    GraphicsApp app = GraphicsApp("dlang - OpenGL 4+ Graphics Framework",4,1);
    app.Loop();
}

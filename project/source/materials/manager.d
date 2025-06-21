import std.stdio;

/// Load all of the materials at run-time in the material manager
/// that are found in the 'pipelines' directory.
shared static this(){
	import std.file;
	foreach(d ; dirEntries("pipelines",SpanMode.shallow)){
		writeln("Found Pipeline: ",d.name);
	}
}

/// Stores all of the materials
struct MaterialManager{
	
}

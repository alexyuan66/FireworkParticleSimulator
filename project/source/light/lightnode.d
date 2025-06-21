module lightnode;

import scene,linear;

/// Basic light interface
class LightNode: ISceneNode{

		enum LightType{POINT,DIRECTIONAL};
	
		LightType mLightType;
		vec3 			mColor;

		override void Update(){
		}

		abstract void RenderQuad();
}

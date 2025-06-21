module directionallight;
import lights, linear;

/// Basic light interface
class DirectionalLight : LightNode{

		vec3 			mDirection;

		this(){
			mLightType = LightType.DIRECTIONAL;
		}

		override void Update(){
		}
}

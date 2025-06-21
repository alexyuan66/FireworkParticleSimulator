module pointlight;
import lights;

/// Basic light interface
class PointLight : LightNode{

		float 			mRadius;

		this(){
			mLightType = LightType.POINT;
		}

		override void Update(){
		}
}

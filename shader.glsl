#define MAX_RAY_STEP 100
#define MAX_DISTANCE 100.
#define MIN_HIT_DIST .001


// Example Pixel Shader

// uniform float exampleUniform;

out vec4 fragColor;


float get_distance(vec3 pos){
	vec4 sphere_origin = vec4(0.,1.,5.,1.);

	float distance_sphere = length(pos-sphere_origin.xyz) - sphere_origin.w;
	float distance_ground = pos.y;

	float distance_surface = min(distance_sphere, distance_ground);

	return distance_surface;

}

// ray_origin = cam_origin
float ray_march(vec3 ray_origin, vec3 ray_direction){
	float distance_origin = 0.;

	for(int i; i<MAX_RAY_STEP; i++){
		vec3 pos = ray_origin + ray_direction * distance_origin;
		float distance_surface = get_distance(pos);
		distance_origin = distance_surface;

		if(distance_origin > MAX_DISTANCE || distance_surface < MIN_HIT_DIST) break;
	}
	return distance_origin;
}


////////////////////////////////
////////////////////////////////
////////////////////////////////
vec4 ray_main(vec2 uv){
	
	vec3 ray_origin = vec3(0., 1., 0.);
	vec3 ray_direction = vec3(uv, 1.);	//nice 
	
	float distance = ray_march(ray_origin, ray_direction);
	
	
	
	return vec4(1.);
}










////////////////////////////////
////////////////////////////////
////////////////////////////////
void main()
{
	vec2 uv = vUV.st * 2. - 1.;
	
	
	
	vec4 color = ray_main(vUV.st);
	fragColor = TDOutputSwizzle(color);

}
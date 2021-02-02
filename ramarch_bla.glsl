uniform vec2 uRes;      //GLSL Top resolution
uniform float iTime;

// raymarcher parameters
uniform int MAX_STEPS;                     // the max steps before giving up
uniform float MIN_SURFACE_DIST;            // the starting distance away from the eye
uniform float MAX_DISTANCE;                // the max distance away from the eye to march before giving up

//Light parameters
uniform float light_energy;
uniform float light_falloff;
uniform int light_type;



// Example Pixel Shader

// uniform float exampleUniform;

float get_distance(vec3 pos){
	vec4 sphere_origin = vec4(0, 0, 6, 1);
	
	
	float sphere_distance = length(pos - sphere_origin.xyz) - sphere_origin.w;
	
	float ground_distance = pos.y;
	
	float d = min(ground_distance, sphere_distance);

    return d;

}



float ray_march(vec3 cam_pos, vec3 ray_direction){
	//Distance traveled so far.
	float distance_origin = 0;
	
	for(int i; i < MAX_STEPS; i++){
		vec3 pos = cam_pos + ray_direction * distance_origin; 
		
		float distance_surface = get_distance(pos);
		
		if( distance_surface < MIN_SURFACE_DIST){
            return distance_origin;
        }
        distance_origin += distance_surface;

        if( distance_origin >= MAX_DISTANCE){
            break;
        }
	}
	return distance_origin;
}

//estimation of the Surface normal at point P
vec3 surface_normal(vec3 pos){

    vec2 e = vec2(0.00001, 0); //small offset to be able to calculate the slope
    float d = get_distance(pos);

    //calculate the slope around the given point to be able to get the normals.
    vec3 normal = vec3(
        d - get_distance(pos - e.xyy),
        d - get_distance(pos - e.yxy),
        d - get_distance(pos - e.yyx)
    );

    //Normalize to get the normal vector.
    return normalize(normal);
}

float global_illumination(vec3 closest_surface_point, vec3 light_position){
    int bounces = 3;
    float distance_traveled = 0.;
    float intensity = 1 ;
    vec3 new_pos = closest_surface_point;
    vec3 new_direction = normalize(light_position - closest_surface_point);


    for(int i; i < bounces; i++){


        vec3 old_pos = new_pos;
        vec3 old_direction = new_direction;
        vec3 new_pos = vec3(old_pos + old_direction * distance_traveled);
        vec3 new_direction = normalize(vec3(old_pos - new_pos));
        vec3 normal_at_point = surface_normal(new_pos);
        
        distance_traveled += ray_march(new_pos + normal_at_point * MIN_SURFACE_DIST, new_direction );
        
        intensity += clamp(dot(new_direction, normal_at_point),0,100000000)/(i*100);
        
    };    
    return intensity;
}

float get_light(vec3 closest_surface_point, vec3 CameraPos){
    vec3 light_position =  vec3(0., 5., 5.);

    //Rotate Light with input
    light_position.xz += vec2(sin(iTime), cos(iTime));

    //Get light direction and the normal vector of the point thats  hit on the surface.
    vec3 light_direction = normalize(light_position - closest_surface_point);
    vec3 normal_vector = surface_normal(closest_surface_point);

    vec3 view_direction = normalize(CameraPos - closest_surface_point);

    float light_intensity = dot(light_direction, normal_vector);
    float spec_intensity = pow(dot(light_direction, view_direction),0.5);
    

    float shadow_distance = ray_march(closest_surface_point + normal_vector * MIN_SURFACE_DIST, light_direction);
    float distance_to_light = length(light_position-closest_surface_point);



    if(shadow_distance < distance_to_light) light_intensity *= .1;
    
    float gi_light = global_illumination(closest_surface_point, light_position) ;//+ light_intensity;
    
    //return shadowing(closest_surface_point, light_position, normal_vector);
    //No Falloff
    float intensity = clamp(light_intensity, 0., 1.);
    //Linear Falloff 
     
    float linear_intensity = intensity * light_energy *( light_falloff / ( light_falloff * distance_to_light));
    //Quadratic Falloff
    float quadratic_intensity = intensity * light_energy *( pow(light_falloff, 2) / ( pow(light_falloff, 2) + pow(distance_to_light, 2)) );

    if(light_type == 0) return intensity;

    if(light_type == 1) return linear_intensity;

    if(light_type == 2) return quadratic_intensity;

    if(light_type == 3) return gi_light;

    

    return quadratic_intensity;
}




out vec4 fragColor;
void main()
{
	vec3 col = vec3(0.);
	
	vec2 uv =(gl_FragCoord.xy - uRes.xy / 2.0)/uRes.y;
	
	//CameraPos or RayOrigin
	vec3 cam_pos = vec3(0.,1.,0.);
	//Ray direction 
	vec3 ray_direction = normalize(vec3(uv.x, uv.y, 1.));
	
	float surface_distance = ray_march(cam_pos, ray_direction);
	
    vec3 closest_surface_point = cam_pos + ray_direction * surface_distance;

    float diffuse = get_light(closest_surface_point);
	
	col = vec3(diffuse); 
	
	vec4 color = vec4(col,1.0);
	fragColor = TDOutputSwizzle(color);


}

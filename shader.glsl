// raymarcher parameters
uniform int MAX_RAY_STEPS;                     // the max steps before giving up
uniform float MIN_SURFACE_DIST;            // the starting distance away from the eye
uniform float MAX_DISTANCE;                // the max distance away from the eye to march before giving up

uniform vec3 uray_origin;
uniform vec2 uRes;      //GLSL Top resolution
uniform float uTime;

//Light parameters
uniform float ulight_energy;
uniform float ulight_falloff;
uniform int ulight_type;
uniform vec3 light_position;

//Material Param
uniform vec3 mat_color;

uniform vec3 gedoens;


out vec4 fragColor;


float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
// https://www.youtube.com/watch?v=AfKGMUDWfuE
float smin( float a, float b, float k ) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0., 1. );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float get_distance2(vec3 pos){
    // vec4 sphere_two_origin;
    // float distance_sphere_two;
    vec4 sphere_origin = vec4(1.,0.,0.,1);
    float distance_surface = length(pos-sphere_origin.xyz) - sphere_origin.w;
    sphere_origin = vec4(-1.,0.,0.,1);
    // distance_surface = min(distance_surface, length(pos-sphere_origin.xyz) - sphere_origin.w);

    // int sphere_count = 0;
    // while(sphere_count < 15){
    //     sphere_two_origin = vec4(0.,(uTime.x * 4.5)*rand(vec2(0,sphere_count)),0.,1);
    //     // if (sphere_count == 14){
    //     //     sphere_two_origin = vec4(0.,(uTime.x+3)*rand(vec2(0,sphere_count)),0.,1+(1+uTime.x)*rand(vec2(0,sphere_count)));
    //     // }
    //     distance_sphere_two = length(pos-sphere_two_origin.xyz) - sphere_two_origin.w;
    //     distance_surface = smin(distance_surface, distance_sphere_two,.2);



    //     sphere_count += 1;
    // }
	return distance_surface;
}

float get_distance(vec3 pos){
    // vec4 sphere_two_origin;
    // float distance_sphere_two;
    vec4 sphere_origin = vec4(1.,0.,0.,1);
    float distance_surface = length(pos-sphere_origin.xyz) - sphere_origin.w;
    sphere_origin = vec4(-1.,0.,0.,1);
    // distance_surface = min(distance_surface, length(pos-sphere_origin.xyz) - sphere_origin.w);

    // int sphere_count = 0;
    // while(sphere_count < 15){
    //     sphere_two_origin = vec4(0.,(uTime.x * 4.5)*rand(vec2(0,sphere_count)),0.,1);
    //     // if (sphere_count == 14){
    //     //     sphere_two_origin = vec4(0.,(uTime.x+3)*rand(vec2(0,sphere_count)),0.,1+(1+uTime.x)*rand(vec2(0,sphere_count)));
    //     // }
    //     distance_sphere_two = length(pos-sphere_two_origin.xyz) - sphere_two_origin.w;
    //     distance_surface = smin(distance_surface, distance_sphere_two,.2);



    //     sphere_count += 1;
    // }
	return distance_surface;
}

float opRep( vec3 p, vec3 c)
{
    vec3 q = mod(p+0.5*c,c)-0.5*c;
    return get_distance( q );
}

float opTwist(  vec3 p )
{
    const float k = 3.0; // or some other amount
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec3  q = vec3(m*p.xz,p.y);
    float result = get_distance(q);
    // result += vec3(0.1, 0.1, 0.1);
    // float result = opRep(q, gedoens);
    return result;
    // return primitive;
}

// ray_origin = cam_origin
float ray_march(vec3 ray_origin, vec3 ray_direction)
{
	float distance_origin = 0.;

	for(int i; i<MAX_RAY_STEPS; i++){
		vec3 pos = ray_origin + ray_direction * distance_origin;
		float distance_surface = opTwist(pos);
		distance_origin += distance_surface;

		if(distance_origin > MAX_DISTANCE || distance_surface < MIN_SURFACE_DIST) break;
	}
	return distance_origin;
}

float ray_march2(vec3 ray_origin, vec3 ray_direction)
{
	float distance_origin = 0.;

	for(int i; i<MAX_RAY_STEPS; i++){
		vec3 pos = ray_origin + ray_direction * distance_origin;
		float distance_surface = get_distance2(pos);
		distance_origin += distance_surface;

		if(distance_origin > MAX_DISTANCE || distance_surface < MIN_SURFACE_DIST) break;
	}
	return distance_origin;
}


//estimation of the Surface normal at point P
vec3 surface_normal(vec3 pos){

    vec2 e = vec2(0.001, 0); //small offset to be able to calculate the slope // IF you decrease the value it affects the gi in a funny weird way no clue why though
    float d = get_distance(pos);

    //calculate the slope around the given point to be able to get the normals.
    vec3 normal = d- vec3(
        get_distance(pos - e.xyy),
        get_distance(pos - e.yxy),
        get_distance(pos - e.yyx)
    );

    //Normalize to get the normal vector.
    return normalize(normal);
}

float global_illumination(vec3 closest_surface_point, vec3 light_position)
{
    int bounces = 3;
    float distance_traveled = 0.;
    float intensity = 0 ;
    vec3 new_pos = closest_surface_point;
    vec3 new_direction = normalize(closest_surface_point - light_position);
    vec3 normal_at_point = surface_normal(new_pos);

    //distance_traveled += ray_march(new_pos = normal_at_point *0.01, new_direction);

    //new_pos = new_pos + distance_traveled * new_direction;

    //intensity = max(max(new_pos.x, new_pos.y), new_pos.y)*0.01;

    //intensity = clamp(distance_traveled,0,1);


    for(int i; i < bounces; i++){


        vec3 old_pos = new_pos;
        vec3 old_direction = new_direction;


        distance_traveled += ray_march(new_pos  + normal_at_point * 0.01 , new_direction );

		vec3 new_pos = vec3(old_pos + old_direction * distance_traveled);
        vec3 normal_at_point = surface_normal(new_pos);

        vec3 new_direction = normalize(vec3(old_pos - new_pos));

        intensity = min(intensity,clamp(dot(new_direction, normal_at_point),0,1));

    };

    return intensity;
}


float get_light(vec3 closest_surface_point, vec3 CameraPos)
{

    vec3 new_light_position = light_position;
    //Rotate Light with input
    new_light_position.xz += vec2(sin(uTime), cos(uTime));

    //Get light direction and the normal vector of the point thats  hit on the surface.
    vec3 light_direction = normalize(new_light_position - closest_surface_point);
    vec3 normal_vector = surface_normal(closest_surface_point);


    float light_intensity = dot(light_direction, normal_vector);


    float shadow_distance = ray_march(closest_surface_point + normal_vector * 0.1, light_direction);
    float distance_to_light = length(new_light_position-closest_surface_point);



    if(shadow_distance < distance_to_light) light_intensity *= 0.1;

    float gi_light = global_illumination(closest_surface_point, new_light_position) ;//+ light_intensity;

    //No Falloff
    float intensity = clamp(light_intensity, 0., 1.)+1;
    //Linear Falloff

    float linear_intensity = intensity * ulight_energy *( ulight_falloff / ( ulight_falloff * distance_to_light));
    //Quadratic Falloff
    float quadratic_intensity = intensity * ulight_energy *( pow(ulight_falloff, 2) / ( pow(ulight_falloff, 2) + pow(distance_to_light, 2)) );

    //Phong shading


    if(ulight_type == 0) return intensity;

    if(ulight_type == 1) return linear_intensity;

    if(ulight_type == 2) return quadratic_intensity;

    return quadratic_intensity;
}



float phong(vec3 closest_surface_point, vec3 CameraPos){

    float ambient = 0.0;
    float shininess = 1.0;
    vec3 new_light_position = light_position;
    new_light_position.xz += vec2(sin(uTime), cos(uTime));

    //Get light direction and the normal vector of the point thats  hit on the surface.
    vec3 light_direction = normalize(new_light_position - closest_surface_point);
    vec3 normal_vector = surface_normal(closest_surface_point);

    vec3 view_direction = normalize(CameraPos - closest_surface_point);


    //  Get light intensity at given point.
    float light_intensity = get_light(closest_surface_point, CameraPos);


    float specular_intensity = pow(max(0.0,dot(reflect(-light_direction, normal_vector), view_direction)), shininess);


    float phong_shading = ambient + light_intensity + specular_intensity;


    return phong_shading;

}



////////////////////////////////
////////////////////////////////
////////////////////////////////
vec4 ray_main(vec2 uv)
{
	vec3 color = vec3(0.);
	// vec3 ray_origin = vec3(-5., 1., 0.);
	vec3 ray_origin = uray_origin;
	vec3 ray_direction = vec3(uv.x, uv.y, 1.);	//nice

    // float geo = ray_march()
	float surface_distance = ray_march(ray_origin, ray_direction);
	float surface_distance2 = ray_march2(ray_origin, ray_direction);
    //float geo_distance = ray_march(ray)

    surface_distance = min(surface_distance, surface_distance2);

	vec3 closest_surface_point = ray_origin + ray_direction * surface_distance;
	float diffuse = get_light(closest_surface_point, ray_origin);
    float phong_mat = phong(closest_surface_point, ray_origin);

	color =    vec3(phong_mat);
	return vec4(color, 1.);
}


void main()
{
	vec2 uv = vUV.st;
	uv = uv - 0.5;	// (gl_FragCoord.xy - 0.5 * uRes.xy)/ uRes.y;

	vec4 color = ray_main(uv);
	fragColor = TDOutputSwizzle(color);
}

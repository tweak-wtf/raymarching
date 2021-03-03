uniform float width;
uniform float height;
#define EPSILON = 0.000000001;

out vec4 fragColor;



bool hit_sphere(vec3 ray_origin, vec3 ray_direction, float radius, vec3 center){

    float a = dot(ray_direction, ray_direction);
    float b = 2*dot(ray_direction,(ray_origin-center));
    float c = dot((ray_origin - center),(ray_origin - center)) - pow(radius,2);

    float hit = b*b - 4*a*c;

    return (hit > 0 );

}


vec4 ray_main(vec2 uv){
    vec4 color = vec4(0.);
    //scene = get_scene_definition();
    vec3 sphere_center = vec3(0., 0., 25.);
    float sphere_radius = 5.0;
    vec3 ray_origin = vec3(0., 4., 0);
    vec3 ray_direction = vec3(uv.x, uv.y, 1);


    for(int i=0; i <= height; i++){
        for(int j=0; j<= width; j++){
            
            if( hit_sphere(ray_origin, ray_direction, sphere_radius, sphere_center)){
                color = vec4(1,1,1,1);                
            }else{
                color = vec4(0.);
            }
        }
    }

    return color;
}







void main()
{
	vec2 uv = vUV.st;
	uv = uv - 0.5;	// (gl_FragCoord.xy - 0.5 * uRes.xy)/ uRes.y;

	vec4 color = ray_main(uv);
	fragColor = TDOutputSwizzle(color);



}

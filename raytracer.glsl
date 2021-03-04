uniform float width;
uniform float height;
#define EPSILON = 0.000000001;

out vec4 fragColor;



bool hit_sphere(vec3 ray_origin, vec3 ray_direction, float radius, vec3 center){
    // We are using the sphere equation to see if the ray hits the sphere
    // The equation is dot((p-sphere_center),(p-sphere_center)) = radius^2
    // When solving that equation with the the ray equation r(t) = origin + distance*direction
    // We get the following t*t(dot(direction,direction))+2(origin-sphere_center)*distance*direction+dot((origin-sphere_center),(origin-sphere_center)) - radius^2
    // Which is a quadratic equation and can either have 2,1 or no real solutions when solving it for t 
    // When solving for t it looks like this:
    //       -B+sqrt(B^2-4AC)               -B-sqrt(B^2-4AC)
    //  t1 = ----------------          t1 = ----------------
    //          2A                              2A
    // below we break up the equation for easier reading and only calculate the part under the square root as this defines the Solutions we will get out of it 

    float a = dot(ray_direction, ray_direction);
    float b = 2*dot(ray_direction,(ray_origin-center));
    float c = dot((ray_origin - center),(ray_origin - center)) - pow(radius,2);

    float hit = (-b+ sqrt(b*b - 4*a*c)) / 2*a;

    return (hit > 0 );

}


vec4 ray_main(vec2 uv){
    vec4 color = vec4(0.);
    //scene = get_scene_definition();
    vec3 sphere_center = vec3(0., 0., 5.);
    float sphere_radius = 1.0;
    vec3 ray_origin = vec3(0., 0., 0);
    vec3 ray_direction = vec3(uv.x, uv.y, 1);

     
    if( hit_sphere(ray_origin, ray_direction, sphere_radius, sphere_center)){
        color = vec4(1,1,1,1);                
    }else{
        color = vec4(0.,0.,0.,1.);
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

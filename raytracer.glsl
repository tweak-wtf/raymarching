uniform float width;
uniform float height;
uniform float minDist;
uniform float maxDist;

#define EPSILON = 0.000000001;
#define OBJECT_ARRAY_SIZE = 10;

out vec4 fragColor;
vec3 calculate_object_normal(float hit_distance, vec3 hit_point){
    // took this from the raymarching but doesnt work properly 
    vec2 offset = vec2(0.0001,0.);

    vec3 normal = (hit_distance - hit_point) - vec3(
        length(hit_point - offset.xyy),
        length(hit_point - offset.yxy),
        length(hit_point - offset.yyx)
    );

    return normal;
}



float hit_sphere(vec3 ray_origin, vec3 ray_direction, float radius, vec3 center){
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
    // If we use the result of the whole equation and just dont care about the negative results we get the closest distance to the Surface we hit.
    // We dont care about the negative results because they would be behind the camera.

    float a = dot(ray_direction, ray_direction);
    float b = 2*dot(ray_direction,(ray_origin-center));
    float c = dot((ray_origin - center),(ray_origin - center)) - pow(radius,2);

    float hit_distance = (-b+ sqrt(b*b - 4*a*c)) / 2*a;

    return hit_distance;

}



vec4 hit(vec3 ray_origin, vec3 ray_direction, vec4[4] scene){
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
    // If we use the result of the whole equation and just dont care about the negative results we get the closest distance to the Surface we hit.
    // We dont care about the negative results because they would be behind the camera.
    float hit_distance;
    float temp_hit_distance = maxDist;
    vec3 surface_normal;

    for(int i=0; i <= 2; i++){
        // The scene consits of spheres at the moment thus we are using a vec4 to store the radius aswell.
        float scene_object_radius;
        vec3 scene_object_origin = scene[i].xyz;

        if(scene[i] != 0.)   scene_object_radius = scene[i].w;

        float a = dot(ray_direction, ray_direction);
        float b = 2*dot(ray_direction,(ray_origin-scene_object_origin));
        float c = dot((ray_origin - scene_object_origin),(ray_origin - scene_object_origin)) - pow(scene_object_radius,2);

        hit_distance = (-b+ sqrt(b*b - 4*a*c)) / 2*a;
        if( hit_distance > minDist && hit_distance < maxDist){
            
            if ( hit_distance < temp_hit_distance){
                temp_hit_distance = hit_distance;
                vec3 temp_hit_point = ray_origin + ray_direction * temp_hit_distance;
                surface_normal = normalize(temp_hit_point - scene_object_origin);
            }
        }
    }
    hit_distance = temp_hit_distance;
    
    return vec4(surface_normal, hit_distance);
}

/*
vec3 normal_shading(vec3 ray_direction, vec3 ray_origin, vec3 center){
    // At some point we add shading here for now its just the surface normal of the sphere.
    // you can calculate the normal of a sphere if you take the closest hitpoint and subtract
    // that with the center of the given sphere. 
    // Then you just need to remap everything to a 0,1 range and tada Normal shading YOOO.
    
    vec3 hit_point = ray_origin + ray_direction *hit_distance;

    vec3 surface_normal = normalize(hit_point - center);

    return 0.5*(surface_normal+1);

}
*/



vec3 BSDF(vec3 surface_normal, vec3 ray_direction, vec3 light_direction){
    
    float shininess = 20;

    
    // Ambient light amount
    // I = ka *Ia
    float ambient_power = 1;
    vec3 ambient_amount = vec3(0.1);
    vec3 ambient_intensity = ambient_amount * ambient_power;

    // Diffuse amount 
    // I = kd * dot(normal, lightdirection)
    vec3 diffuse_amount = vec3(0.5, 0.5, 0.5);

    vec3 diffuse_intensity = diffuse_amount * clamp(dot(light_direction, surface_normal),0,1); // dot()
    // Specular amount 
    // I = ks* dot(view_direction, reflected_vector)^shininess
    vec3 specular_amount = vec3(1);
    vec3 specular_intensity = specular_amount * clamp(pow( dot(ray_direction,reflect(-light_direction, surface_normal)), shininess),0,1);


    return ambient_intensity + diffuse_intensity + specular_intensity;
}



vec4[4] get_scene_objects(){

    vec4[4] objects_in_scene;

    objects_in_scene[0] = vec4(0., 0., 6., 1.);
    objects_in_scene[1] = vec4(-2., 0., 5., 0.3);
    objects_in_scene[2] = vec4(2., 0., 10., .5);
    //objects_in_scene[3] = vec4(0., -2., 10., .1);
    //objects_in_scene[4] = vec4(0., 5., 8., 1.);
    
    
    
    return objects_in_scene;
}




vec4 ray_main(vec2 uv){
    // Main Ray function calls all the shit we need to have a cool image in the end.


    vec3 surface_normal;
    vec4 color = vec4(0.);
    //scene = get_scene_definition();
    vec3 sphere_center = vec3(0., 0., 5.);
    float sphere_radius = 1.0;
    vec3 ray_origin = vec3(0., 0., 0.);
    vec3 focus_point = vec3(0., 0., 0.);
    vec3 camera_view_direction = normalize(focus_point - ray_origin);
    vec3 ray_direction = normalize(ray_origin + vec3(uv.x, uv.y, 1.));//normalize(vec3(0,0,0) - ray_origin);



    vec4[4] scene_objects = get_scene_objects();
    vec4 hit_distance_with_normal  = hit(ray_origin, ray_direction, scene_objects);
    float hit_distance = hit_distance_with_normal.w;
    surface_normal = hit_distance_with_normal.xyz; 

    //float hit_distance = hit_sphere(ray_origin, ray_direction, sphere_radius, sphere_center);
    vec3 hit_point = ray_origin + ray_direction*hit_distance;
    vec3 light_origin = vec3(0., -10., 0.);
    vec3 light_direction = normalize((hit_point - light_origin));
    //surface_normal = calculate_object_normal(hit_distance, hit_point);
    //surface_normal = normalize(hit_point - sphere_center);
    if( hit_distance > minDist && hit_distance < maxDist){
        color += vec4(BSDF(surface_normal, ray_direction, light_direction),1);                
    }else{
        color = vec4(0.,0.,0.,1.);
    }
    //color = vec4(ray_direction,1);
    
    return color;
}







void main()
{
	vec2 uv = vUV.st;
	uv = uv -0.5 ;	// (gl_FragCoord.xy - 0.5 * uRes.xy)/ uRes.y;
    /* vec2 uv = gl_FragCoord.xy/vec2(width,height);
    
	uv = uv * 2.0 - 1.0;//transform from [0,1] to [-1,1]
    uv.x *= width / height; //aspect fix
 */
	vec4 color = ray_main(uv);
	fragColor = TDOutputSwizzle(color);
}

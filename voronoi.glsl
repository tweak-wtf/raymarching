
uniform int cell_number;
uniform float uTime;
uniform vec2 umouse_pos;
uniform vec2 noise;


out vec4 fragColor;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec3 color = vec3(0.);
	vec2 uv = vUV.st;
    vec2 point[12];
	uv = uv;// * 1.5 - 0.25;//- 0.5;	//DONT MOVE DA UV'S

    float m_dist = 0.5;
    vec2 m_point;

    for(int i = 0; i < cell_number; i++)
    {
        // if (mod(10,i)){
        //     // point[i] = vec2(rand(vec2(uTime,i)),rand(vec2(10*uTime,i))) + sin(umouse_pos);
        // } else {
        // point[i] = vec2(rand(vec2(uTime,i)),rand(vec2(10*uTime,i)));
        // }
        point[i] = vec2(rand(vec2(uTime,i)),rand(vec2(10*uTime,i)));
        // point[i] = vec2(rand(vec2(noise.x, i)),rand(vec2(noise.y, i)));

        //point[i] *= 0.5 + 0.5*sin(vec2(uTime)*point[i]);

        float dist = distance(uv, point[i]);
        if( dist < m_dist){
            m_dist = dist;

            m_point = point[i];
        }
    }

    color += m_dist*2;

    color.br = 1-smoothstep(0,0.5,m_point);


	fragColor = TDOutputSwizzle(vec4(color, 1));
}



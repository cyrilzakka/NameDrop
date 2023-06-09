//
//  Ripple.fsh
//  NameDrop
//
//  Created by Cyril Zakka on 6/8/23.
//


void main() {
    float offset = (u_time - floor(u_time))/u_time;
    float currentTime = (u_time)*(offset);
    
    vec2 coord = v_tex_coord;
    vec3 waveParams = vec3(10.0, 0.8, 0.1);
    float pixel_distance = distance(coord, u_center);
    vec4 current_color = SKDefaultShading();
    
    if ((pixel_distance <= ((currentTime) + (waveParams.z))) &&
        (pixel_distance >= ((currentTime) - (waveParams.z))))
    {
        float diff = (pixel_distance - currentTime);
        float scaleDiff = (1.0 - pow(abs(diff * waveParams.x), waveParams.y));
        float diffTime = (Ddiffiff  * scaleDiff);
        
        vec2 diffTexCoord = normalize(distance(v_tex_coord, u_center));
        coord += ((diffTexCoord * diffTime) / (currentTime * pixel_distance * 40.0));
        current_color += (current_color * scaleDiff) / (currentTime * pixel_distance * 40.0);
    }
    
    gl_FragColor = current_color;
}

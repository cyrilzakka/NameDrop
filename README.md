# NameDrop
Water ripple effect written in SwiftUI/GLSL to replicate the NameDrop animation first demoed on iOS 17. Should be easier to add with the new `.layerEffect` modifier. The magic mostly happens in this little block of code:
```
        void main() {
            float offset = (u_time - floor(u_time))/u_time;
            float currentTime = u_time*offset*0.5;
            vec3 waveParams = vec3(u_scale, u_sharpness, u_spread);
            vec2 waveCenter = vec2(0.5, 1.05);
        
            vec2 coord = v_tex_coord;
            float dist = distance(coord, waveCenter);
            vec4 current_color = texture2D(u_texture, coord);
        
            //Only distort the pixels within the parameter distance from the center
            if ((dist <= ((currentTime) + (waveParams.z))) &&
                (dist >= ((currentTime) - (waveParams.z)))) {
                float diff = (dist - currentTime);
                float scaleDiff = (1.0 - pow(abs(diff * waveParams.x), waveParams.y));
                float diffTime = (diff  * scaleDiff);
                vec2 diffTexCoord = normalize(coord - waveCenter);
                coord += ((diffTexCoord * diffTime) / (currentTime * dist * 10)); //40
                current_color = texture2D(u_texture, coord);
                current_color += (current_color * scaleDiff) / (currentTime * dist * 40.0);
            }
            
            gl_FragColor = current_color;
```
Give me a shoutout if you end up using it anywhere! 

Twitter: [@cyrilzakka](https://twitter.com/cyrilzakka)

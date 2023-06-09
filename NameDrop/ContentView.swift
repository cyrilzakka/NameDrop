//
//  ContentView.swift
//  NameDrop
//
//  Created by Cyril Zakka on 6/5/23.
//

import SwiftUI
import SpriteKit

extension ContentView {
    class WaterScene: SKScene {
        private let spriteNode = SKSpriteNode()
        var image: UIImage?
        
        // Converted from: https://www.shadertoy.com/view/llj3Dz
        let waterShader = SKShader(source: """
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
        }
        """)
        
        override func sceneDidLoad() {
            backgroundColor = .clear
            scaleMode = .resizeFill

            spriteNode.shader = waterShader
            addChild(spriteNode)
        }
        
        func updateTexture() {
            guard view != nil else { return }
            guard let image else { return }

            let texture = SKTexture(image: image)
            spriteNode.texture = texture
            spriteNode.size = texture.size()
            spriteNode.position.x = frame.midX
            spriteNode.position.y = frame.midY
        }

        override func didMove(to view: SKView) {
            updateTexture()
        }
    }
    
    struct WaterEffect<Content: View>: View {
        @State private var scene = WaterScene()
        @Environment(\.displayScale) var displayScale

        var scale: Double
        var sharpness: Double
        var spread: Double
        @ViewBuilder var content: () -> Content
        
        var body: some View {
            let renderer = ImageRenderer(content: content())
            renderer.scale = displayScale
            
            let image = renderer.uiImage
            let size = image?.size ?? .zero
            
            scene.waterShader.uniforms = [
                SKUniform(name: "u_scale", float: Float(scale)),
                SKUniform(name: "u_sharpness", float: Float(sharpness)),
                SKUniform(name: "u_spread", float: Float(spread))
            ]
            
            scene.image = image
            scene.updateTexture()
            
            return SpriteView(scene: scene, options: .allowsTransparency)
                .frame(width: size.width, height: size.height)
        }
    }
}

struct ContentView: View {
    
    @State private var showControls = true
    @State private var scale = 10.0
    @State private var sharpness = 0.8
    @State private var spread = 0.1
    
    var body: some View {
            WaterEffect(scale: scale, sharpness: sharpness, spread: spread) {
                ZStack(alignment: .top) {
                    Image("wallpaper")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    VStack(alignment: .center) {
                        Text("Friday, June 9")
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                        Text("11:42")
                            .font(.system(size: 70))
                            .fontWeight(.semibold)
                        
                        Text("Cyril Zakka")
                        
                    }
                    .padding(.top, 115)
                    .foregroundColor(.white.opacity(0.7))
                }
            }.sheet( isPresented: $showControls, content: {
                ScrollView {
                    VStack {
                        LabeledContent("Scale") {
                            Slider(value: $scale, in: 1...50, step: 1)
                        }
                        
                        LabeledContent("Sharpness") {
                            Slider(value: $sharpness, in: 0...1, step: 0.1)
                        }
                        
                        LabeledContent("Spread") {
                            Slider(value: $spread, in: 0...1, step: 0.1)
                        }
                    }.padding()
                }.presentationBackground(.thinMaterial)
                .padding()
                .presentationDetents([.fraction(0.3),.medium, .large])
            })
    }
}

#Preview {
    ContentView()
}

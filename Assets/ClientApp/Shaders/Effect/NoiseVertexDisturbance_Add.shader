// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "D3/Effect/NoiseVertexDisturbance_Add" {
    Properties {
        _TintColor ("Color_copy", Color) = (1,1,1,1)
        _basecolor ("basecolor", 2D) = "white" {}
        _rotate2 ("rotate2", Float ) = 0.2
        _rotate3 ("rotate3", Float ) = 0.1
        _speed02 ("speed02", Float ) = 0.2
        _ColorMultiply ("ColorMultiply", Range(1, 4)) = 1
        _ColorPower ("ColorPower", Range(1, 4)) = 1
        _displacestreth ("displacestreth", Float ) = 1
        _displaceDirection ("displaceDirection", Vector) = (0,0,1,0)
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            #pragma glsl
            uniform float4 _TimeEditor;
            uniform float4 _TintColor;
            uniform sampler2D _basecolor; uniform float4 _basecolor_ST;
            uniform float _displacestreth;
            uniform float _rotate2;
            uniform float _rotate3;
            uniform float _speed02;
            uniform float _ColorMultiply;
            uniform float _ColorPower;
            uniform float4 _displaceDirection;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                float4 node_3413 = _Time + _TimeEditor;
                float node_8744 = (node_3413.g*_speed02);
                float4 node_4995 = _Time + _TimeEditor;
                float node_9087_ang = node_4995.g;
                float node_9087_spd = _rotate2;
                float node_9087_cos = cos(node_9087_spd*node_9087_ang);
                float node_9087_sin = sin(node_9087_spd*node_9087_ang);
                float2 node_9087_piv = float2(0.5,0.5);
                float2 node_9087 = (mul(o.uv0-node_9087_piv,float2x2( node_9087_cos, -node_9087_sin, node_9087_sin, node_9087_cos))+node_9087_piv);
                float4 node_2652 = tex2Dlod(_basecolor,float4(TRANSFORM_TEX(node_9087, _basecolor),0.0,0));
                float3 node_9120 = frac(((node_8744+(1.0 - node_2652.rgb))-0.5));
                float node_495_ang = node_4995.g;
                float node_495_spd = _rotate3;
                float node_495_cos = cos(node_495_spd*node_495_ang);
                float node_495_sin = sin(node_495_spd*node_495_ang);
                float2 node_495_piv = float2(0.5,0.5);
                float2 node_495 = (mul(o.uv0-node_495_piv,float2x2( node_495_cos, -node_495_sin, node_495_sin, node_495_cos))+node_495_piv);
                float4 node_6209 = tex2Dlod(_basecolor,float4(TRANSFORM_TEX(node_495, _basecolor),0.0,0));
                float3 node_2275 = frac((node_8744+node_6209.rgb));
                float3 node_2289 = (((1.0 - node_9120)*node_9120)+((1.0 - node_2275)*node_2275));
                v.vertex.xyz += (node_2289*_displaceDirection.rgb*_displacestreth);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 node_3413 = _Time + _TimeEditor;
                float node_8744 = (node_3413.g*_speed02);
                float4 node_4995 = _Time + _TimeEditor;
                float node_9087_ang = node_4995.g;
                float node_9087_spd = _rotate2;
                float node_9087_cos = cos(node_9087_spd*node_9087_ang);
                float node_9087_sin = sin(node_9087_spd*node_9087_ang);
                float2 node_9087_piv = float2(0.5,0.5);
                float2 node_9087 = (mul(i.uv0-node_9087_piv,float2x2( node_9087_cos, -node_9087_sin, node_9087_sin, node_9087_cos))+node_9087_piv);
                float4 node_2652 = tex2D(_basecolor,TRANSFORM_TEX(node_9087, _basecolor));
                float3 node_9120 = frac(((node_8744+(1.0 - node_2652.rgb))-0.5));
                float node_495_ang = node_4995.g;
                float node_495_spd = _rotate3;
                float node_495_cos = cos(node_495_spd*node_495_ang);
                float node_495_sin = sin(node_495_spd*node_495_ang);
                float2 node_495_piv = float2(0.5,0.5);
                float2 node_495 = (mul(i.uv0-node_495_piv,float2x2( node_495_cos, -node_495_sin, node_495_sin, node_495_cos))+node_495_piv);
                float4 node_6209 = tex2D(_basecolor,TRANSFORM_TEX(node_495, _basecolor));
                float3 node_2275 = frac((node_8744+node_6209.rgb));
                float3 node_2289 = (((1.0 - node_9120)*node_9120)+((1.0 - node_2275)*node_2275));
                float3 emissive = ((pow((node_2289*_ColorMultiply),_ColorPower)*_TintColor.rgb)*i.vertexColor.a);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Mobile/Particles/Additive"
}

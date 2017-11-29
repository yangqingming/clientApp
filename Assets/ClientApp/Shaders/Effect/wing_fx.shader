// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "D3/Effect/wing_fx" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _ColorTex ("ColorTex", 2D) = "white" {}
        _speed ("speed", Float ) = -0.05
        _speed01 ("speed01", Float ) = -0.2
        _ColorFix ("ColorFix", Color) = (0.391147,0.600004,0.806,1)
        _fx2 ("fx2", 2D) = "black" {}
        _uvoffset ("uvoffset", Range(-1, 1)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent+400"
            "RenderType"="Transparent"
        }
        LOD 200
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11 d3d11_9x xbox360 xboxone ps3 ps4 psp2 
           // #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _ColorTex; uniform float4 _ColorTex_ST;
            uniform float _speed;
            uniform float _speed01;
            uniform float4 _ColorFix;
            uniform sampler2D _fx2; uniform float4 _fx2_ST;
            uniform float _uvoffset;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float UV_U = i.uv0.r;
                float4 node_5590 = _Time + _TimeEditor;
                float UV_V = i.uv0.g;
                float2 node_8461 = float2((UV_U+(node_5590.g*_speed)),UV_V);
                float4 node_6317 = tex2D(_ColorTex,node_8461);
                float2 node_1410 = float2((UV_U+(node_5590.g*(_speed+(-0.4)))),UV_V);
                float4 _fx2_var = tex2D(_fx2,TRANSFORM_TEX(node_1410, _fx2));
                float2 node_68 = ((float2(node_6317.r,node_6317.g)*i.vertexColor.a*_uvoffset)+i.uv0);
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_68, _MainTex));
                float2 node_2106 = float2((UV_U+(node_5590.g*(_speed+_speed01))),UV_V);
                float4 node_4784 = tex2D(_ColorTex,node_2106);
                float3 emissive = ((((node_6317.rgb+_fx2_var.rgb)*_MainTex_var.r)+(node_4784.rgb*_MainTex_var.g)+(_MainTex_var.b-(_MainTex_var.r+_MainTex_var.g)))*_ColorFix.rgb);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,_MainTex_var.b);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "D3/Effect/Fallback/wing_fx_fallback"
        }


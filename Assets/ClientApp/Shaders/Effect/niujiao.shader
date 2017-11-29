// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//2015.11.18
//two texture layer,vertex color alpha to control the color of top and bottom
//out color and exp
//V is up

Shader "D3/Effect/niujiao" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Freqency ("Freqency", Range(1, 200)) = 1
        _TopColor ("TopColor", Color) = (0.3897059,0.1661981,0.3003027,1)
        _BottomColor ("BottomColor", Color) = (1,0.7655172,0,1)
        _HotFxPower ("HotFxPower", Range(0, 1)) = 0.2
        _MainTex ("MainTex", 2D) = "white" {}
        _Layer01_U ("Layer01_U", Float ) = -0.1
        _Layer01_V ("Layer01_V", Float ) = -0.1
        _Layer02_U ("Layer02_U", Float ) = 0.15
        _Layer02_V ("Layer02_V", Float ) = -0.15
        _Fx_texture ("Fx_texture", 2D) = "white" {}
        _Fx_texture_speed ("Fx_texture_speed", Float ) = -0.2
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11 d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 2.0
            uniform float4 _TimeEditor;
            uniform float4 _Color;
            uniform float _HotFxPower;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float _Layer01_U;
            uniform float _Layer01_V;
            uniform float _Layer02_U;
            uniform float _Layer02_V;
            uniform sampler2D _Fx_texture; uniform float4 _Fx_texture_ST;
            uniform float _Fx_texture_speed;
            uniform float4 _TopColor;
            uniform float4 _BottomColor;
            uniform float _Freqency;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float UVCoord_U = i.uv0.r;
                float4 node_4365 = _Time + _TimeEditor;
                float UVCoord_V = i.uv0.g;
                float2 node_3341 = float2(UVCoord_U,((_Fx_texture_speed*node_4365.g)+UVCoord_V));
                float4 _Fx_texture_var = tex2D(_Fx_texture,TRANSFORM_TEX(node_3341, _Fx_texture));
                float2 UVCoord_UV = i.uv0;
                float2 node_5464 = (UVCoord_UV+float2((node_4365.g*_Layer01_U),(node_4365.g*_Layer01_V)));
                float4 node_4246 = tex2D(_MainTex,node_5464);
                float2 node_1581 = (UVCoord_UV+float2((node_4365.g*_Layer02_U),(node_4365.g*_Layer02_V)));
                float4 node_161 = tex2D(_MainTex,node_1581);
                float3 emissive = ((((i.vertexColor.a*_Fx_texture_var.rgb)+node_4246.rgb+node_161.rgb)*((_TopColor.rgb*(1.0 - i.vertexColor.a))+(i.vertexColor.a*_BottomColor.rgb)))+(i.vertexColor.a*_HotFxPower)+(pow(1.0-max(0,dot(normalDirection, viewDirection)),(sin((node_4365.g*_Freqency))+1.6))*_Color.rgb));
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//2015.11.30
//Specularmask:R=skin,G=cloth,B=betal,A=opacity clip
//2015.12.24 
//Add R channel emission slider
//2015.12.29
//Add Normal
//2016.01.03
//Add Lod
//Add FallBack

Shader "D3/player_show_OpacityClip" {
Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _Normal ("Normal", 2D) = "gray" {}
        _Specularmask ("Specularmask", 2D) = "black" {}
        _RLevel ("RLevel", Range(-1, 1)) = -0.5
        _RGloss ("RGloss", Range(0, 2)) = 0.63
        _SkinSelfEmission ("SkinSelfEmission", Range(0, 1)) = 0.5
        _GLevel ("GLevel", Range(-1, 1)) = 0.06
        _GGloss ("GGloss", Range(0, 2)) = 0.54
        _BLevel ("BLevel", Range(0, 2)) = 0.64
        _BGloss ("BGloss", Range(0, 2)) = 0.54
        _BroderLightColor ("BroderLightColor", Color) = (0.1299193,0.3070427,0.5176471,1)
        _BroderLightWide ("BroderLightWide", Range(0, 10)) = 5
        _Y_fade ("Y_fade", Float ) = 2
        _ScanTex ("ScanTex", 2D) = "black" {}
        _ScanColor ("ScanColor", Color) = (1,1,1,1)
        _ScanAngle ("ScanAngle", Range(-1, 1)) = 0
        _ScanSpeed ("ScanSpeed", Range(0, 1)) = 0.2
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
        LOD 200
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
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11 d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float4 _TimeEditor;
            uniform sampler2D _Specularmask; uniform float4 _Specularmask_ST;
            uniform float _RLevel;
            uniform float _GLevel;
            uniform float _BLevel;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float _BroderLightWide;
            uniform float _RGloss;
            uniform float _GGloss;
            uniform float _BGloss;
            uniform float _Y_fade;
            uniform float4 _BroderLightColor;
            uniform sampler2D _ScanTex; uniform float4 _ScanTex_ST;
            uniform float4 _ScanColor;
            uniform float _ScanAngle;
            uniform float _ScanSpeed;
            uniform float _SkinSelfEmission;
            uniform sampler2D _Normal; uniform float4 _Normal_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _Normal_var = UnpackNormal(tex2D(_Normal,TRANSFORM_TEX(i.uv0, _Normal)));
                float3 normal = _Normal_var.rgb;
                float3 normalLocal = normal;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float2 MainUV = i.uv0;
                float2 node_4863 = MainUV;
                float4 _Specularmask_var = tex2D(_Specularmask,TRANSFORM_TEX(node_4863, _Specularmask));
                float MainAlpha = _Specularmask_var.a;
                clip(MainAlpha - 0.5);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float node_6189 = _Specularmask_var.b;
                float FinalGloss = ((_Specularmask_var.r*_RGloss)+(_Specularmask_var.g*_GGloss)+(node_6189*_BGloss));
                float gloss = FinalGloss;
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float2 node_8983 = MainUV;
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_8983, _MainTex));
                float node_1598 = _Specularmask_var.r;
                float FinalSpecular = (_MainTex_var.a*((node_1598*_RLevel)+(_Specularmask_var.g*_GLevel)+(_Specularmask_var.b*_BLevel)));
                float node_5262 = FinalSpecular;
                float3 specularColor = float3(node_5262,node_5262,node_5262);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float3 MainTexRGB = _MainTex_var.rgb;
                float3 diffuseColor = MainTexRGB;
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
////// Emissive:
                float SpMask_RChannel = node_1598;
                float node_155_ang = _ScanAngle;
                float node_155_spd = 1.0;
                float node_155_cos = cos(node_155_spd*node_155_ang);
                float node_155_sin = sin(node_155_spd*node_155_ang);
                float2 node_155_piv = float2(0.5,0.5);
                float4 node_1329 = _Time + _TimeEditor;
                float2 node_155 = (mul(float2(i.uv0.r,(i.uv0.g+(node_1329.g*_ScanSpeed)))-node_155_piv,float2x2( node_155_cos, -node_155_sin, node_155_sin, node_155_cos))+node_155_piv);
                float4 _ScanTex_var = tex2D(_ScanTex,TRANSFORM_TEX(node_155, _ScanTex));
                float3 FinalEmission = ((MainTexRGB*SpMask_RChannel*_SkinSelfEmission)+(pow((1.0-max(0,dot(i.normalDir,viewDirection))),_BroderLightWide)*(i.posWorld.g*_Y_fade)*_BroderLightColor.rgb)+(node_6189*_ScanTex_var.rgb*_ScanColor.rgb));
                float3 emissive = FinalEmission;
/// Final Color:
                float3 finalColor = diffuse + specular + emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11 d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float4 _TimeEditor;
            uniform sampler2D _Specularmask; uniform float4 _Specularmask_ST;
            uniform float _RLevel;
            uniform float _GLevel;
            uniform float _BLevel;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float _BroderLightWide;
            uniform float _RGloss;
            uniform float _GGloss;
            uniform float _BGloss;
            uniform float _Y_fade;
            uniform float4 _BroderLightColor;
            uniform sampler2D _ScanTex; uniform float4 _ScanTex_ST;
            uniform float4 _ScanColor;
            uniform float _ScanAngle;
            uniform float _ScanSpeed;
            uniform float _SkinSelfEmission;
            uniform sampler2D _Normal; uniform float4 _Normal_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _Normal_var = UnpackNormal(tex2D(_Normal,TRANSFORM_TEX(i.uv0, _Normal)));
                float3 normal = _Normal_var.rgb;
                float3 normalLocal = normal;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float2 MainUV = i.uv0;
                float2 node_4863 = MainUV;
                float4 _Specularmask_var = tex2D(_Specularmask,TRANSFORM_TEX(node_4863, _Specularmask));
                float MainAlpha = _Specularmask_var.a;
                clip(MainAlpha - 0.5);
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float node_6189 = _Specularmask_var.b;
                float FinalGloss = ((_Specularmask_var.r*_RGloss)+(_Specularmask_var.g*_GGloss)+(node_6189*_BGloss));
                float gloss = FinalGloss;
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float2 node_8983 = MainUV;
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_8983, _MainTex));
                float node_1598 = _Specularmask_var.r;
                float FinalSpecular = (_MainTex_var.a*((node_1598*_RLevel)+(_Specularmask_var.g*_GLevel)+(_Specularmask_var.b*_BLevel)));
                float node_5262 = FinalSpecular;
                float3 specularColor = float3(node_5262,node_5262,node_5262);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 MainTexRGB = _MainTex_var.rgb;
                float3 diffuseColor = MainTexRGB;
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor * 1,0);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11 d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _Specularmask; uniform float4 _Specularmask_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float2 MainUV = i.uv0;
                float2 node_4863 = MainUV;
                float4 _Specularmask_var = tex2D(_Specularmask,TRANSFORM_TEX(node_4863, _Specularmask));
                float MainAlpha = _Specularmask_var.a;
                clip(MainAlpha - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "D3/FallBack/player_show_OpacityClip_lod"}

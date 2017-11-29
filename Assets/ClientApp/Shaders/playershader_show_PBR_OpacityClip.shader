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
//2016.05
//Upgrade to PBR lighting 
//2016.08
//PBR lighting is useing GGX
//Remove shader LOD

Shader "D3/Player/playershow_PBR_OpacityClip" {
Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Specularmask ("Specularmask", 2D) = "black" {}
        _RLevel ("RLevel", Range(-2, 2)) = -0.5
        _RGloss ("RGloss", Range(0, 4)) = 0.63
        _SkinSelfEmission ("SkinSelfEmission", Range(0, 1)) = 0.5
        _GLevel ("GLevel", Range(-2, 2)) = 0.06
        _GGloss ("GGloss", Range(0, 4)) = 0.54
        _BLevel ("BLevel", Range(-2, 2)) = 0.64
        _BGloss ("BGloss", Range(0, 4)) = 0.54
        _BroderLightWide ("BroderLightWide", Range(0, 10)) = 5
        _Y_fade ("Y_fade", Float ) = 2
        _BroderLightColor ("BroderLightColor", Color) = (0.1299193,0.3070427,0.5176471,1)
        _ScanTex ("ScanTex", 2D) = "black" {}
        _ScanColor ("ScanColor", Color) = (1,0.857462,0.791,1)
        _ScanAngle ("ScanAngle", Range(-1, 1)) = 0
        _ScanSpeed ("ScanSpeed", Range(0, 1)) = 0.2
        _Cube ("Cube", Cube) = "_Skybox" {}
        _CubePower ("CubePower", Range(0, 1)) = 0.5
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
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
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
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
            uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
            uniform samplerCUBE _Cube;
            uniform float _CubePower;
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
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float2 MainUV = i.uv0;
                float2 node_5697 = MainUV;
                float3 _NormalMap_var = UnpackNormal(tex2D(_NormalMap,TRANSFORM_TEX(node_5697, _NormalMap)));
                float3 Normal = _NormalMap_var.rgb;
                float3 normalLocal = Normal;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float2 node_9188 = MainUV;
                float4 _Specularmask_var = tex2D(_Specularmask,TRANSFORM_TEX(node_9188, _Specularmask));
                float AlphaClip = _Specularmask_var.a;
                clip(AlphaClip - 0.5);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float node_5186 = _Specularmask_var.b;
                float FinalGloss = ((_Specularmask_var.r*_RGloss)+(_Specularmask_var.g*_GGloss)+(node_5186*_BGloss));
                float gloss = FinalGloss;
                float specPow = exp2( gloss * 10.0+1.0);
/////// GI Data:
                UnityLight light;
                #ifdef LIGHTMAP_OFF
                    light.color = lightColor;
                    light.dir = lightDirection;
                    light.ndotl = LambertTerm (normalDirection, light.dir);
                #else
                    light.color = half3(0.f, 0.f, 0.f);
                    light.ndotl = 0.0f;
                    light.dir = half3(0.f, 0.f, 0.f);
                #endif
                UnityGIInput d;
                d.light = light;
                d.worldPos = i.posWorld.xyz;
                d.worldViewDir = viewDirection;
                d.atten = attenuation;
                d.boxMax[0] = unity_SpecCube0_BoxMax;
                d.boxMin[0] = unity_SpecCube0_BoxMin;
                d.probePosition[0] = unity_SpecCube0_ProbePosition;
                d.probeHDR[0] = unity_SpecCube0_HDR;
                d.boxMax[1] = unity_SpecCube1_BoxMax;
                d.boxMin[1] = unity_SpecCube1_BoxMin;
                d.probePosition[1] = unity_SpecCube1_ProbePosition;
                d.probeHDR[1] = unity_SpecCube1_HDR;
                Unity_GlossyEnvironmentData ugls_en_data;
                ugls_en_data.roughness = 1.0 - gloss;
                ugls_en_data.reflUVW = viewReflectDirection;
                UnityGI gi = UnityGlobalIllumination(d, 1, normalDirection, ugls_en_data );
                lightDirection = gi.light.dir;
                lightColor = gi.light.color;
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float LdotH = max(0.0,dot(lightDirection, halfDirection));
                float node_7038 = _Specularmask_var.r;
                float FinalMetallic = ((node_7038*_RLevel)+(_Specularmask_var.g*_GLevel)+(_Specularmask_var.b*_BLevel));
                float3 specularColor = FinalMetallic;
                float specularMonochrome;
                float2 node_7614 = MainUV;
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_7614, _MainTex));
                float3 FinalBaseColor = _MainTex_var.rgb;
                float3 diffuseColor = FinalBaseColor; // Need this for specular when using metallic
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, specularMonochrome );
                specularMonochrome = 1.0-specularMonochrome;
                float NdotV = max(0.0,dot( normalDirection, viewDirection ));
                float NdotH = max(0.0,dot( normalDirection, halfDirection ));
                float VdotH = max(0.0,dot( viewDirection, halfDirection ));
                float visTerm = SmithJointGGXVisibilityTerm( NdotL, NdotV, 1.0-gloss );
                float normTerm = max(0.0, GGXTerm(NdotH, 1.0-gloss));
                float specularPBL = (NdotL*visTerm*normTerm) * (UNITY_PI / 4);
                if (IsGammaSpace())
                    specularPBL = sqrt(max(1e-4h, specularPBL));
                specularPBL = max(0, specularPBL * NdotL);
                float3 directSpecular = (floor(attenuation) * _LightColor0.xyz)*specularPBL*lightColor*FresnelTerm(specularColor, LdotH);
                half grazingTerm = saturate( gloss + specularMonochrome );
                float3 indirectSpecular = (gi.indirect.specular);
                indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
                float3 specular = (directSpecular + indirectSpecular);
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
                float nlPow5 = Pow5(1-NdotL);
                float nvPow5 = Pow5(1-NdotV);
                float3 directDiffuse = ((1 +(fd90 - 1)*nlPow5) * (1 + (fd90 - 1)*nvPow5) * NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
////// Emissive:
                float MaskRChannel = node_7038;
                float node_3225 = node_5186;
                float node_4922_ang = _ScanAngle;
                float node_4922_spd = 1.0;
                float node_4922_cos = cos(node_4922_spd*node_4922_ang);
                float node_4922_sin = sin(node_4922_spd*node_4922_ang);
                float2 node_4922_piv = float2(0.5,0.5);
                float4 node_7040 = _Time + _TimeEditor;
                float2 node_4922 = (mul(float2(i.uv0.r,(i.uv0.g+(node_7040.g*_ScanSpeed)))-node_4922_piv,float2x2( node_4922_cos, -node_4922_sin, node_4922_sin, node_4922_cos))+node_4922_piv);
                float4 _ScanTex_var = tex2D(_ScanTex,TRANSFORM_TEX(node_4922, _ScanTex));
                float3 FinalEmission = ((FinalBaseColor*MaskRChannel*_SkinSelfEmission)+(pow((1.0-max(0,dot(i.normalDir,viewDirection))),_BroderLightWide)*(i.posWorld.g*_Y_fade)*_BroderLightColor.rgb)+(node_3225*_ScanTex_var.rgb*_ScanColor.rgb)+(node_3225*texCUBE(_Cube,viewReflectDirection).rgb*_CubePower));
                float3 emissive = FinalEmission;
/// Final Color:
                float3 finalColor = diffuse + specular + emissive;
                return fixed4(finalColor,1);
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
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
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
            uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
            uniform samplerCUBE _Cube;
            uniform float _CubePower;
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
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float2 MainUV = i.uv0;
                float2 node_5697 = MainUV;
                float3 _NormalMap_var = UnpackNormal(tex2D(_NormalMap,TRANSFORM_TEX(node_5697, _NormalMap)));
                float3 Normal = _NormalMap_var.rgb;
                float3 normalLocal = Normal;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float2 node_9188 = MainUV;
                float4 _Specularmask_var = tex2D(_Specularmask,TRANSFORM_TEX(node_9188, _Specularmask));
                float AlphaClip = _Specularmask_var.a;
                clip(AlphaClip - 0.5);
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
///////// Gloss:
                float node_5186 = _Specularmask_var.b;
                float FinalGloss = ((_Specularmask_var.r*_RGloss)+(_Specularmask_var.g*_GGloss)+(node_5186*_BGloss));
                float gloss = FinalGloss;
                float specPow = exp2( gloss * 10.0+1.0);
////// Specular:
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float LdotH = max(0.0,dot(lightDirection, halfDirection));
                float node_7038 = _Specularmask_var.r;
                float FinalMetallic = ((node_7038*_RLevel)+(_Specularmask_var.g*_GLevel)+(_Specularmask_var.b*_BLevel));
                float3 specularColor = FinalMetallic;
                float specularMonochrome;
                float2 node_7614 = MainUV;
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_7614, _MainTex));
                float3 FinalBaseColor = _MainTex_var.rgb;
                float3 diffuseColor = FinalBaseColor; // Need this for specular when using metallic
                diffuseColor = DiffuseAndSpecularFromMetallic( diffuseColor, specularColor, specularColor, specularMonochrome );
                specularMonochrome = 1.0-specularMonochrome;
                float NdotV = max(0.0,dot( normalDirection, viewDirection ));
                float NdotH = max(0.0,dot( normalDirection, halfDirection ));
                float VdotH = max(0.0,dot( viewDirection, halfDirection ));
                float visTerm = SmithJointGGXVisibilityTerm( NdotL, NdotV, 1.0-gloss );
                float normTerm = max(0.0, GGXTerm(NdotH, 1.0-gloss));
                float specularPBL = (NdotL*visTerm*normTerm) * (UNITY_PI / 4);
                if (IsGammaSpace())
                    specularPBL = sqrt(max(1e-4h, specularPBL));
                specularPBL = max(0, specularPBL * NdotL);
                float3 directSpecular = attenColor*specularPBL*lightColor*FresnelTerm(specularColor, LdotH);
                float3 specular = directSpecular;
/////// Diffuse:
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
                float nlPow5 = Pow5(1-NdotL);
                float nvPow5 = Pow5(1-NdotV);
                float3 directDiffuse = ((1 +(fd90 - 1)*nlPow5) * (1 + (fd90 - 1)*nvPow5) * NdotL) * attenColor;
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse + specular;
                return fixed4(finalColor * 1,0);
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
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
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
                float2 node_9188 = MainUV;
                float4 _Specularmask_var = tex2D(_Specularmask,TRANSFORM_TEX(node_9188, _Specularmask));
                float AlphaClip = _Specularmask_var.a;
                clip(AlphaClip - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Standard"
    }

// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon_Builtin"
{
	Properties
	{
		_ASEOutlineColor( "Outline Color", Color ) = (0,0,0,0)
		_ASEOutlineWidth( "Outline Width", Float ) = 0
		_HighlightMap("Highlight Map", 2D) = "white" {}
		_Texture("Texture", 2D) = "white" {}
		_HighlightAdjustment("Highlight Adjustment", Range( -1 , 1)) = 0.3516684
		_ShadowAdjustment("Shadow Adjustment", Range( -1 , 1)) = 0
		_HighlightStrength("Highlight Strength", Range( 0 , 1)) = 0.6819456
		_ShadowStrength("Shadow Strength", Range( 0 , 1)) = 0.6
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		float4 _ASEOutlineColor;
		float _ASEOutlineWidth;
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += ( v.normal * _ASEOutlineWidth );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _ASEOutlineColor.rgb;
			o.Alpha = 1;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _HighlightAdjustment;
		uniform sampler2D _HighlightMap;
		uniform float _HighlightStrength;
		uniform float _ShadowAdjustment;
		uniform float _ShadowStrength;
		uniform sampler2D _Texture;
		uniform float4 _Texture_ST;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			ase_vertexNormal = normalize( ase_vertexNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult20 = normalize( ase_worldlightDir );
			float dotResult15 = dot( ase_vertexNormal , normalizeResult20 );
			float4 tex2DNode5 = tex2D( _HighlightMap, i.uv_texcoord );
			float blendOpSrc26 = ( dotResult15 > _HighlightAdjustment ? 1.0 : 0.0 );
			float blendOpDest26 = tex2DNode5.g;
			float lerpBlendMode26 = lerp(blendOpDest26,( 1.0 - ( 1.0 - blendOpSrc26 ) * ( 1.0 - blendOpDest26 ) ),_HighlightStrength);
			float4 temp_cast_0 = (( saturate( lerpBlendMode26 ))).xxxx;
			float blendOpSrc28 = ( dotResult15 > _ShadowAdjustment ? 1.0 : 0.0 );
			float blendOpDest28 = tex2DNode5.r;
			float lerpBlendMode28 = lerp(blendOpDest28,( blendOpSrc28 * blendOpDest28 ),_ShadowStrength);
			float4 temp_cast_1 = (( saturate( lerpBlendMode28 ))).xxxx;
			float2 uv_Texture = i.uv_texcoord * _Texture_ST.xy + _Texture_ST.zw;
			float4 blendOpSrc33 = temp_cast_1;
			float4 blendOpDest33 = tex2D( _Texture, uv_Texture );
			float4 blendOpSrc32 = temp_cast_0;
			float4 blendOpDest32 = ( saturate( ( blendOpSrc33 * blendOpDest33 ) ));
			o.Emission = ( saturate( 2.0f*blendOpDest32*blendOpSrc32 + blendOpDest32*blendOpDest32*(1.0f - 2.0f*blendOpSrc32) )).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.RangedFloatNode;17;624.4802,662.1367;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;15;622.2844,454.7043;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;462.7084,562.696;Inherit;False;Property;_HighlightAdjustment;Highlight Adjustment;2;0;Create;True;0;0;0;True;0;False;0.3516684;-0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;799.6467,219.4768;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;8;522.372,298.9277;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;10;216.2461,291.8574;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;11;-76.42446,552.0782;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BlendOpsNode;28;1234.666,621.2749;Inherit;True;Multiply;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;470.4996,774.7952;Inherit;False;Property;_ShadowAdjustment;Shadow Adjustment;3;0;Create;True;0;0;0;True;0;False;0;-0.25;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;29;856.9763,681.6365;Inherit;True;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;1180.655,311.6128;Inherit;True;Property;_Texture;Texture;1;0;Create;True;0;0;0;True;0;False;c3a8aa9417aab4c388b0320c62ee611a;c3a8aa9417aab4c388b0320c62ee611a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;31;1496.866,315.3349;Inherit;True;Property;_TextureSample1;Texture Sample 1;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;33;1838.791,315.5824;Inherit;True;Multiply;True;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;429.1411,84.13077;Inherit;True;Property;_HighlightMap;Highlight Map;0;0;Create;True;0;0;0;True;0;False;f9f3a5157a4da4e2abdf4d8563b5d128;f9f3a5157a4da4e2abdf4d8563b5d128;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Compare;14;874.5095,-37.20429;Inherit;True;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;26;1210.516,7.556357;Inherit;True;Screen;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;32;2090.852,306.8443;Inherit;True;SoftLight;True;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;27;880.2761,429.7486;Inherit;False;Property;_HighlightStrength;Highlight Strength;4;0;Create;True;0;0;0;True;0;False;0.6819456;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;875.0707,526.3027;Inherit;False;Property;_ShadowStrength;Shadow Strength;5;0;Create;True;0;0;0;True;0;False;0.6;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;20;250.2464,547.0128;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2349.837,303.0573;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Toon_Builtin;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;True;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;10;0
WireConnection;15;1;20;0
WireConnection;5;0;2;0
WireConnection;5;1;8;0
WireConnection;28;0;29;0
WireConnection;28;1;5;1
WireConnection;28;2;30;0
WireConnection;29;0;15;0
WireConnection;29;1;22;0
WireConnection;29;2;17;0
WireConnection;31;0;4;0
WireConnection;33;0;28;0
WireConnection;33;1;31;0
WireConnection;14;0;15;0
WireConnection;14;1;19;0
WireConnection;14;2;17;0
WireConnection;26;0;14;0
WireConnection;26;1;5;2
WireConnection;26;2;27;0
WireConnection;32;0;26;0
WireConnection;32;1;33;0
WireConnection;20;0;11;0
WireConnection;0;2;32;0
ASEEND*/
//CHKSM=598AFB801B18BD6020CF14A2EB90F31683627649
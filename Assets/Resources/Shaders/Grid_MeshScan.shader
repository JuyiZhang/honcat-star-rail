// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Grid_MeshScan"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_GridColor("Grid Color", Color) = (0.240566,0.8768758,1,0)
		_Speed("Speed", Range( 0 , 10)) = 0.2
		_LoopInterval("Loop Interval", Range( 0 , 10)) = 0.5
		_LineThickness("Line Thickness", Range( 0.5 , 1)) = 0.757
		_GridSize("Grid Size", Range( 0 , 1)) = 0.1
		_ScanThickness("Scan Thickness", Range( 0 , 1)) = 0.1969565
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _GridSize;
		uniform float _LineThickness;
		uniform float4 _GridColor;
		uniform float _Speed;
		uniform float _LoopInterval;
		uniform float _ScanThickness;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 temp_cast_0 = (( 1.0 / _GridSize )).xx;
			float temp_output_2_0_g1 = _LineThickness;
			float2 appendResult10_g2 = (float2(temp_output_2_0_g1 , temp_output_2_0_g1));
			float2 temp_output_11_0_g2 = ( abs( (frac( (i.uv_texcoord*temp_cast_0 + float2( 0,0 )) )*2.0 + -1.0) ) - appendResult10_g2 );
			float2 break16_g2 = ( 1.0 - ( temp_output_11_0_g2 / fwidth( temp_output_11_0_g2 ) ) );
			float temp_output_2_0 = saturate( min( break16_g2.x , break16_g2.y ) );
			float4 temp_output_15_0 = ( temp_output_2_0 < 1.0 ? _GridColor : float4( 0,0,0,0 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float mulTime5 = _Time.y * _Speed;
			float temp_output_22_0 = ( ( mulTime5 % ( ( _Speed * _LoopInterval ) + 2.0 ) ) - 1.0 );
			float temp_output_39_0 = (( ase_vertex3Pos.y >= ( temp_output_22_0 - _ScanThickness ) && ase_vertex3Pos.y <= temp_output_22_0 ) ? 1.0 :  0.0 );
			float4 temp_cast_1 = (temp_output_39_0).xxxx;
			float4 blendOpSrc27 = temp_output_15_0;
			float4 blendOpDest27 = temp_cast_1;
			float4 color48 = IsGammaSpace() ? float4(0.2264151,0.2264151,0.2264151,0) : float4(0.04193995,0.04193995,0.04193995,0);
			float4 blendOpSrc47 = temp_output_15_0;
			float4 blendOpDest47 = color48;
			float4 blendOpSrc49 = ( saturate( min( blendOpSrc27 , blendOpDest27 ) ));
			float4 blendOpDest49 = ( saturate( ( blendOpSrc47 * blendOpDest47 ) ));
			o.Emission = ( saturate( ( 1.0 - ( 1.0 - blendOpSrc49 ) * ( 1.0 - blendOpDest49 ) ) )).rgb;
			o.Alpha = 1;
			float temp_output_50_0 = ( 1.0 - temp_output_2_0 );
			clip( temp_output_50_0 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.SimpleTimeNode;5;-579.4123,245.5524;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;1.142096,215.9875;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-212.031,383.6255;Inherit;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;15;10.74731,-414.4752;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-229.2527,-391.4752;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;2;-308.7394,-643.4741;Inherit;True;Grid;-1;;1;a9240ca2be7e49e4f9fa3de380c0dbe9;0;3;5;FLOAT2;8,8;False;6;FLOAT2;0,0;False;2;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;177.8568,303.5987;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;180.4698,470.7437;Inherit;False;Constant;_Float2;Float 2;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;34;-226.6859,51.88504;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;45;-559.1352,-661.1077;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-782.6172,-708.9047;Inherit;False;Constant;_Float6;Float 6;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-674.728,-529.9749;Inherit;False;Property;_LineThickness;Line Thickness;4;0;Create;True;0;0;0;False;0;False;0.757;0.9;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-913.5267,-639.3059;Inherit;False;Property;_GridSize;Grid Size;5;0;Create;True;0;0;0;True;0;False;0.1;8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-280.4538,-295.1531;Inherit;False;Property;_GridColor;Grid Color;1;0;Create;True;0;0;0;True;0;False;0.240566,0.8768758,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;48;2.884054,-101.1462;Inherit;False;Constant;_Color0;Color 0;5;0;Create;True;0;0;0;False;0;False;0.2264151,0.2264151,0.2264151,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1442.312,-310.424;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Grid_MeshScan;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.BlendOpsNode;49;1036.053,-116.3745;Inherit;True;Screen;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-136.4071,481.1465;Inherit;False;Property;_ScanThickness;Scan Thickness;6;0;Create;True;0;0;0;False;0;False;0.1969565;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareWithRange;39;414.3903,100.8611;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;47;435.2029,-135.342;Inherit;True;Multiply;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;27;719.592,-390.574;Inherit;True;Darken;True;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleRemainderNode;17;-211.1641,265.7244;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;50;477.2163,-629.9652;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;51;753.0461,-24.08796;Inherit;True;Darken;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-513.4349,349.8239;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1146.512,343.5193;Inherit;False;Property;_LoopInterval;Loop Interval;3;0;Create;True;0;0;0;True;0;False;0.5;3;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1149.597,235.9886;Inherit;False;Property;_Speed;Speed;2;0;Create;True;0;0;0;True;0;False;0.2;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-767.4349,524.7884;Inherit;False;Constant;_Float1;Float 1;7;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-762.8751,350.9236;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;5;0;25;0
WireConnection;22;0;17;0
WireConnection;22;1;23;0
WireConnection;15;0;2;0
WireConnection;15;1;16;0
WireConnection;15;2;10;0
WireConnection;2;5;45;0
WireConnection;2;2;44;0
WireConnection;40;0;22;0
WireConnection;40;1;41;0
WireConnection;45;0;46;0
WireConnection;45;1;43;0
WireConnection;0;2;49;0
WireConnection;0;10;50;0
WireConnection;49;0;27;0
WireConnection;49;1;47;0
WireConnection;39;0;34;2
WireConnection;39;1;40;0
WireConnection;39;2;22;0
WireConnection;39;3;20;0
WireConnection;47;0;15;0
WireConnection;47;1;48;0
WireConnection;27;0;15;0
WireConnection;27;1;39;0
WireConnection;17;0;5;0
WireConnection;17;1;52;0
WireConnection;50;0;2;0
WireConnection;51;0;50;0
WireConnection;51;1;39;0
WireConnection;52;0;55;0
WireConnection;52;1;53;0
WireConnection;55;0;25;0
WireConnection;55;1;18;0
ASEEND*/
//CHKSM=AC7E321F776C87A8E61BA80D69A134979040B29A
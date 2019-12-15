/*文件名：Crush.shader
作者：YZY
说明：破碎与合并：
上次修改时间：2019/12/14
*/
Shader "MyShader/Crush"
{
	Properties{
		_MainTex("Texture", 2D) = ""{}
		_BlendTex("BlendTexture", 2D) = ""{}
		_Emission("Emission",Range(0,1)) = 0.5
		_CutAxis("Cut Axis", Vector) = (0,1,0,0)
		_CutCenter("Cut Center", Vector) = (0,1,0,0)
			_PlayerPos("PlayerPos", Vector) = (0,1,0,0)
		_CutThreshold("Cut Threshold", Float) = 0.5
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend Mode", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend Mode", Float) = 1
	}
		SubShader
		{
			CGINCLUDE
			#include "UnityCG.cginc"

			float4 _CutAxis;
			float4 _CutCenter;
			float4 _PlayerPos;
			float _CutThreshold;
			sampler2D _MainTex;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;

			};
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 worldPos   : TEXCOORD1;
				float3 normal : TEXCOORD2;
			};

			float cutPosition(float3 pos) {
				float dir = length(pos - _CutCenter);
				//if(dir> _CutThreshold)
				return dir;
				//return 1;
			}
			float3 twist(float3 p,float3 center, float power) {
				float s = sin(power*p.x);
				float c = cos(power*p.z);
				//百度：旋转矩阵
				float3x3 m = float3x3(
					c, -s,0,
					s, c, 0,
					0, 0, 1
					);
				return mul(m, p - center);
			}
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = v.vertex;
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.normal = v.normal;
				return o;
			}
			[maxvertexcount(21)]
			void geom(triangle v2f v[3], inout TriangleStream<v2f>  tristream)
			{
				float3 center = (v[0].vertex.xyz + v[1].vertex.xyz + v[2].vertex.xyz) / 3;
				float power = cutPosition(center);
				for (int i = 0; i < 3; i++) {
					v2f o = v[i];
					if (power > _CutThreshold) {
						v[i].vertex.xyz = twist(v[i].vertex.xyz, center, 1);
						v[i].vertex.xyz += (center - _CutCenter.xyz)*power;
					}
					o.vertex = UnityObjectToClipPos(v[i].vertex.xyz);
					tristream.Append(o);
				}
				tristream.RestartStrip();
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
			//col.a=1- saturate( col.a*cutPosition(i.worldPos.xyz)*_CutThreshold);
			return col;
			}
				ENDCG

				Pass
			{
				CGPROGRAM

			#pragma vertex vert
	#pragma geometry geom
	#pragma fragment frag

					ENDCG
			}

				Pass
				{
					Cull Front
					CGPROGRAM
					#pragma vertex vert
					#pragma geometry geom
					#pragma fragment frag

			ENDCG
				}
		}

}
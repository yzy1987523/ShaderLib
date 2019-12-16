/*文件名：Rot.shader
作者：YZY
说明：加厚
上次修改时间：2019/12/16
*/
Shader "MyShader/Rot"
{
	Properties{
		_MainTex("Texture", 2D) = ""{}
		_BlendTex("BlendTexture", 2D) = ""{}
		_Emission("Emission",Range(0,1)) = 0.5
		_CutAxis("Cut Axis", Vector) = (0,1,0,0)
		_CutCenter("Cut Center", Vector) = (0,1,0,0)
			_PlayerPos("PlayerPos", Vector) = (0,1,0,0)
		_CutThreshold("Cut Threshold", Float) = 0.01
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
				float dir =saturate(length(pos - _CutCenter)-2.5);
				return dir;
			}
			float3 twist(float3 p, float3 center, float3 power,float power1) {
				float t = _Time.y;
				if (t > 360) {
					t -= 360;
				}
				float a = power.x*power1*t*0.03;
				float b = power.y*power1*t*0.03;
				float c = power.z*power1*t*0.03;
				float cosA = cos(a);
				float cosB = cos(b);
				float cosC = cos(c);
				float sinA = sin(a);
				float sinB = sin(b);
				float sinC = sin(c);			
				//百度：旋转矩阵
				float3x3 m = float3x3(
					cosA*cosC-cosB*sinA*sinC, -cosB*cosC*sinA-cosA*sinC, sinA*sinB,
					cosC*sinA+cosA*cosB*sinC, cosA*cosB*cosC-sinA*sinC, -cosA*sinB,
					sinB*sinC, cosC*sinB, cosB
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
#define ADD_VERT(v,_uv) \
                       o.vertex = UnityObjectToClipPos(v);\
                       o.uv=_uv;\
						tristream.Append(o);
#define ADD_TRI(p0, p1, p2,uv0,uv1,uv2) \
                       ADD_VERT(p0,uv0) \
                       ADD_VERT(p1,uv1) \
                       ADD_VERT(p2,uv2) \
			tristream.RestartStrip();
			[maxvertexcount(30)]
			void geom(triangle v2f v[3], inout TriangleStream<v2f>  tristream)
			{
				v2f o = v[0];
				//float r = v[0].vertex.x+v[0].vertex.z;
				float3 edgeA = v[1].vertex.xyz - v[0].vertex.xyz;
				float3 edgeB = v[2].vertex.xyz - v[0].vertex.xyz;
				float3 normal = normalize(cross(edgeA, edgeB))*0.2; //法线
				float3 center = ((v[0].vertex.xyz + v[1].vertex.xyz + v[2].vertex.xyz) / 3+normal*0.5);
				float pow = cutPosition(center);
				float3 v0 = v[0].vertex.xyz;
				float3 v1 = v[1].vertex.xyz;
				float3 v2 = v[2].vertex.xyz ;
				float3 v3 = v[0].vertex.xyz + normal;
				float3 v4 = v[1].vertex.xyz + normal;
				float3 v5 = v[2].vertex.xyz + normal;
				
				v0 = twist(v0, center, center,pow) + center*(1+pow*3);
				v1 = twist(v1, center, center,pow) + center*(1+pow*3);
				v2 = twist(v2, center, center,pow) + center*(1+pow*3);
				v3 = twist(v3, center, center,pow) + center*(1+pow*3);
				v4 = twist(v4, center, center,pow) + center*(1+pow*3);
				v5 = twist(v5, center, center,pow) + center*(1+pow*3);

					//v0+=center*1;
					//v1+=center*1;
					//v2+=center*1;
					//v3+=center*1;
					//v4+=center*1;
					//v5+=center*1;
				float2 suv0 = v[0].uv;
				float2 suv1 = v[1].uv;	
				float2 suv2 = v[2].uv;
				float2 suv3 = v[0].uv;
				float2 suv4 = v[1].uv;
				float2 suv5 = v[2].uv;

				
				ADD_TRI(v2, v5, v1, suv2, suv5, suv1);
				ADD_TRI(v2, v1, v0, suv2, suv1, suv0);				
				ADD_TRI(v1, v4, v0, suv1, suv4, suv0);
				ADD_TRI(v4, v3, v0, suv4, suv3, suv0);
				ADD_TRI(v0, v3, v2, suv0, suv3, suv2);
				ADD_TRI(v5, v4, v1, suv5, suv4, suv1);
				ADD_TRI(v3, v5, v2, suv3, suv5, suv2);
				ADD_TRI(v5, v3, v4, suv5, suv3, suv4);
				
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

			//	Pass
			//	{
			//		Cull Front
			//		CGPROGRAM
			//		#pragma vertex vert
			//		#pragma geometry geom
			//		#pragma fragment frag

			//ENDCG
			//	}
		}

}
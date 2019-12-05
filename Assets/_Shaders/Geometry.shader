/*文件名：Geometry.shader
作者：YZY
说明：应用到几何着色器
上次修改时间：2019/12/5
*/
Shader "MyShader/Geometry"  
{  
    Properties{          
        _MainTex("Texture", 2D) = ""{}  
		_BlendTex("BlendTexture", 2D) = ""{}
		_Emission("Emission",Range(0,1))=0.5
		_CutAxis("Cut Axis", Vector) = (0,1,0,0)
		_CutCenter("Cut Center", Vector) = (0,1,0,0)
		_CutThreshold("Cut Threshold", Float) = 0.5
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend Mode", Float)  = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend Mode", Float)  = 1
    }  
    SubShader
    {		
		CGINCLUDE
		#include "UnityCG.cginc"
		
		float4 _CutAxis;
		float4 _CutCenter;
		float _CutThreshold;
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
			return saturate(dot(pos-_CutCenter,normalize(_CutAxis.xyz)));		
		}
      float3 twist(float3 p, float power){
        float s = sin(power * p.y);
        float c = cos(power * p.y);
		//百度：旋转矩阵
        float3x3 m = float3x3(
           c,0,s,
		   0,1,0,
		   -s,0,c
         );
         return mul(m, p);
      }
		
			
		ENDCG
		Pass
		{			
			CGPROGRAM
			#pragma vertex vert

#pragma fragment frag
			sampler2D _BlendTex;
		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
			o.normal = v.normal;
			return o;
		}
			fixed4 frag(v2f i) : SV_Target
			{
				return tex2D(_BlendTex, i.uv);
			}
			ENDCG
		}
		Pass
        { 
			Blend[_SrcBlend][_DstBlend]
            CGPROGRAM 
			sampler2D _MainTex;
#pragma vertex vert

#pragma fragment frag
			#pragma geometry geom
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
				float3 normal = normalize(v[0].normal + v[1].normal + v[2].normal);
				for (int i = 0; i < 3; i++) {
					float power = cutPosition(v[i].worldPos.xyz);
					v2f o = v[i];
					v[i].vertex.xyz += normal * power * (1 +v[i].vertex.y);
					v[i].vertex.xyz = twist(v[i].vertex.xyz, 10* power);
					o.vertex = UnityObjectToClipPos(v[i].vertex.xyz);
					tristream.Append(o);
				}
				tristream.RestartStrip();
			}

			fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				col.a=1- saturate( col.a*cutPosition(i.worldPos.xyz)*_CutThreshold);
                return col;
            }
            ENDCG
        }
    }
}  
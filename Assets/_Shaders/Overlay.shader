/*文件名：Overlay.shader
作者：YZY
说明：动态的线条
上次修改时间：2019/12/21
*/
Shader "MyShader/Overlay"
{
	Properties{
		_Color("Color", Color) = (0,1,0,0)
		_Color1("Color1", Color) = (0,1,0,0)
		
	}
	SubShader
	{
		CGINCLUDE
		#include "UnityCG.cginc"
		fixed4 _Color;
		fixed4 _Color1;
		fixed _temp;
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
		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos( v.vertex);
			o.uv = v.uv;
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
			o.normal = v.normal;
			return o;
		}
		fixed4 frag(v2f i) : SV_Target
		{
			fixed4 col=fixed4(0,0,0,1);			
			//绘制一个圆
			//col = step(length(i.uv - fixed2(0.5, 0.5)), 0.5);
			//绘制一个环	
		fixed x = i.uv.x - 0.5-0.05*cos(_Time.y*2);
		fixed y = i.uv.y - 0.5-0.05*sin(_Time.y * 1);
		fixed width = saturate(abs(1/(30*sqrt((x*x+y*y)))));
		
			col = fixed4(width, width, width,1);
		
			col *= _Color;

			fixed x1 = i.uv.x - 0.5 - 0.05*cos(_Time.y * 3-180);
			fixed y1 = i.uv.y - 0.5 - 0.05*sin(_Time.y * 2-180);
			fixed width1 =saturate(abs(1 / (50* sqrt((x1*x1 + y1 * y1)))));

			fixed col1 = fixed4(width1, width1, width1, 1);

			col1 *= _Color1;
			//col+= step(length(i.uv - fixed2(0.5, 0.5)), 0.3);
			//col *= _Color1;
			//col += step(length(i.uv - fixed2(0.5, 0.5)), 0.2);
			//col *= _Color;
			return col+col1;
		}
		ENDCG

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}

}
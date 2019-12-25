/*文件名：Cloud.shader
作者：YZY
说明：云图
上次修改时间：2019/12/21
*/
Shader "MyShader/XY"
{
	Properties
	{
		_X("X",float) =0
		_Y("Y",float) = 0
		_Width("Width",float)=1
		_MainTex("Texture", 2D) = ""{}
		_Color("Color",Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags{
			"RenderType" = "Transparent"
			}
		CGINCLUDE
		#include "UnityCG.cginc"
		float _X;
		float _Y;
		float _Width;
		fixed4 _Color;
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
			fixed4 col = tex2D(_MainTex, i.uv);
		for (int j = 0; j < 5; j++) {
			i.uv.y += ((_Y*sin((i.uv.x)*_X+j/7.0 + _Time.y))-0.1 );
			fixed w = abs(1 / (_Width*i.uv.y));
			col += (fixed4(w, w, w, w)*_Color);
		}
			return col;
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
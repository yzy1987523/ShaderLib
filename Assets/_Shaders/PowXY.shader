/*文件名：PowXY.shader
作者：YZY
说明：带平方的方程
上次修改时间：2020/1/4
*/
Shader "MyShader/PowXY"
{
	Properties
	{
		_X("X",float) = 0
		_Y("Y",float) = 0
		_Width("Width",float) = 1
		_Height("Height",float)=1
		_Lamda("Lamda",float) = 1
		_MainTex("Texture", 2D) = ""{}
		_Color("Color",Color) = (1,1,1,1)
		//[Enum(SIN,0,COS,1,TAN,2,EXP,3,TEST,4)] _Type("CurveType", Float) = 4
	}
	SubShader
	{
		Tags{
			"RenderType" = "Transparent"
			}
		CGINCLUDE
		#include "UnityCG.cginc"
		//#pragma multi_compile _SIN _COS _X2 _X3??
		float _X;
		float _Y;
		float _Width;
		float _Height;
		float _Lamda;
		//Float _Type;
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
		//圆或椭圆
		fixed fun(v2f i) {
			fixed d = sqrt(abs(pow(_X*(i.uv.x - 0.5), 2) + pow(_Y*(i.uv.y - 0.5), 2)));
			return 1 - (saturate(d - (_Lamda + _Width)) + saturate((_Lamda - _Width) - d));
		}
		fixed4 frag(v2f i) : SV_Target
		{ 
			fixed4 col = tex2D(_MainTex, i.uv);
			float w = fun(i);			
			col += fixed4(w, w, w, w)*_Color;
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
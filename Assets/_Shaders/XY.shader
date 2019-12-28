/*文件名：Cloud.shader
作者：YZY
说明：云图
上次修改时间：2019/12/21
*/
Shader "MyShader/XY"
{
	Properties
	{
		_X("X",float) = 0
		_Y("Y",float) = 0
		_Width("Width",float) = 1
		_Height("Height",float)=1
		_MainTex("Texture", 2D) = ""{}
		_Color("Color",Color) = (1,1,1,1)
		[Enum(SIN,0,COS,1,TAN,2,EXP,3,TEST,4)] _Type("CurveType", Float) = 4
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
		Float _Type;
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
	
		fixed Fun1(fixed _x) {
			return sin(_x);
		}
		
		fixed Fun2(fixed _x) {
			return cos( _x ) ;
		}
	
		fixed Fun3(fixed _x) {
			return tan(_x);
		}	
		fixed Fun4(fixed _x) {
			return exp(_x);
		}
		//test
		fixed Fun5(fixed _x) {
			
			return pow(2,_x);
		}
		fixed crossLineX() {
			return 0.5;
		}
		fixed4 frag(v2f i) : SV_Target
		{ 
			fixed4 col = tex2D(_MainTex, i.uv);
			fixed x = _Width * (i.uv.x-0.5) - _X*0.01;//减0.5是为了居中；乘0.01是为了将坐标系单位放大100倍
			fixed y = Fun1(x);
			if (_Type == 1) {
				y = Fun2(x);
			}
			else if (_Type == 2) {
				y = Fun3(x);
			}
			else if (_Type == 3) {
				y = Fun4(x);
			}
			else if (_Type ==4) {
				y = Fun5(x);
			}
			fixed temp = i.uv.y;
			i.uv.y += -_Height*(y+_Y)*0.01;//乘0.01是为了将坐标系单位放大100倍
			fixed w = abs(1 / (100*(i.uv.y-0.5)));//减0.5是为了居中
			col += (fixed4(w, w, w, 1)*_Color);
			w= abs(1 / (7000 * (temp- 0.5)));
			col+= (fixed4(w, w, w, 1));
			w = abs(1/(7000*(i.uv.x - 0.5)));
			col += (fixed4(w, w, w, 1));
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
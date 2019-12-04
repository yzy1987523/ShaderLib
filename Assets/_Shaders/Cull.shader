//实现一个满足以下条件的shader：
//1.可以动态改变裁切区域
//2.如果需要剖面，可以添加一个Pass，并且Cull Front
Shader "MyShader/CustomCull"{
	Properties{
		_MainTex("MainTexture",2D) = ""{}
		_BlendTex("BlendTexture",2D) = ""{}
		_CutAxis("Cut Axis", Vector) = (0,1,0,0)
		_CutCenter("Cut Center", Vector) = (0,1,0,0)
		_CutThreshold("Cut Threshold", Float) = 0.5
	}
	SubShader{
		CGINCLUDE
		#include "UnityCG.cginc"
		#pragma vertex vert
		#pragma fragment frag
		#pragma shader_feature MASK_SPHERE  MASK_PLANE
		float4 _CutAxis;
		float4 _CutCenter;
		float _CutThreshold;

		struct appdata {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
		struct v2f {
			float4 vertex : SV_POSITION;
			float2 uv : TEXCOORD0;
			float4 worldPos : TEXCOORD1;
		};

		float cutPosition(float3 pos) {
		#if MASK_PLANE			
			return dot(pos-_CutCenter,normalize(_CutAxis.xyz));
		#elif MASK_SPHERE
			return distance(pos,_CutCenter)-_CutThreshold;
		#else
			return 0.0;
		#endif
		}
		

		v2f vert(appdata v) {
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);		
			return o;
		}
		ENDCG
		Pass{
			CGPROGRAM
			sampler2D _MainTex;
		
			fixed4 frag(v2f i) : SV_Target {
				if (cutPosition(i.worldPos.xyz) > 0) discard;
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
		Pass{			 
			CGPROGRAM	
			sampler2D _BlendTex;
			fixed4 frag(v2f i) : SV_Target {
				if (cutPosition(i.worldPos.xyz) < 0) discard;
				fixed4 col=tex2D(_BlendTex, i.uv);
				return col;
			}
			ENDCG			
			}
		}
	}

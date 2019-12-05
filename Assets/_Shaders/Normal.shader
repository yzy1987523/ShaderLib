/*文件名：Normal.shader
作者：YZY
说明：就是普通的法线，法线总是要涉及到灯光的
上次修改时间：2019/12/5
*/
Shader "MyShader/Normal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BlendTex("BlendTexture",2D) = ""{}
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
		#pragma vertex vert
		#pragma fragment frag
		
		float4 _CutAxis;
		float4 _CutCenter;
		float _CutThreshold;
		struct appdata
        {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;

		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float2 uv : TEXCOORD0;
			float4 worldPos : TEXCOORD1;
		};
		float cutPosition(float3 pos) {		
			return saturate(dot(pos-_CutCenter,normalize(_CutAxis.xyz)));		
		}
		v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;				
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);	
            return o;
        }
			
		ENDCG
       
		Pass
        {
            CGPROGRAM    
			sampler2D _BlendTex;
			fixed4 frag (v2f i) : SV_Target
            {              
                return  tex2D(_BlendTex, i.uv);
            }
            ENDCG
        }
		Pass
        { 
			Blend[_SrcBlend][_DstBlend]
            CGPROGRAM 
			sampler2D _MainTex;
			sampler2D _NormalTex;
			fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				col.a=col.a*cutPosition(i.worldPos.xyz)*_CutThreshold;
                return col;
            }
            ENDCG
        }
    }
}

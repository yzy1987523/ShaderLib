/*文件名：Blend.shader
作者：YZY
说明：测试不同Blend组合的效果
上次修改时间：2019/12/6
*/
Shader "MyShader/Blend"  
{  
    //属性  
    Properties{          
        _MainTex("Texture", 2D) = ""{}	
		_Color("Color",Color)=(1,0,0,1)
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend Mode", Float)  = 1
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend Mode", Float)  = 1
    }  
    //子着色器    
    SubShader  
    {      
		Blend[_SrcBlend][_DstBlend]
		CGINCLUDE  
		#include "Lighting.cginc"              
		sampler2D _MainTex;
		fixed4 _Color;
		struct appdata {
			float4 vertex : POSITION;
			float4 uv : TEXCOORD0;
		};
		struct v2f  
		{  
		    float4 pos : SV_POSITION;  
		    float2 uv : TEXCOORD0;  
		}; 
  
		
		v2f vert(appdata v)  
		{  
		    v2f o;  
		    o.pos = UnityObjectToClipPos(v.vertex);  		   
			o.uv=v.uv;
		    return o;  
		} 

		fixed4 frag(v2f i) : SV_Target  
		{		
		    fixed4 color = tex2D(_MainTex, i.uv);  
			color=_Color*color;
			color.a=_Color.a;
		    return color;  
		}
		ENDCG  
		Pass  
		{ 
			CGPROGRAM	
			#pragma vertex vert  
			#pragma fragment frag 
			ENDCG	
		}
	}  
}  
/*文件名：Normal.shader
作者：YZY
说明：就是普通的法线，法线总是要涉及到光照计算，没有光照就看不出凹凸变化
上次修改时间：2019/12/5
*/
Shader "MyShader/Normal"  
{  
    //属性  
    Properties{          
        _MainTex("Texture", 2D) = ""{}  
        _Normal("Normal", 2D) = ""{}  
		_Emission("Emission",Range(0,1))=0.5
    }  
    //子着色器    
    SubShader  
    {      
		CGINCLUDE  
		#include "Lighting.cginc"              
		sampler2D _MainTex;  
		sampler2D _Normal; 		            
		float _Emission;		
		struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;//切线方向
			float3 normal : NORMAL;//法线方向
			float4 uv : TEXCOORD0;
		};
		struct v2f  
		{  
		    float4 pos : SV_POSITION;  
		    float2 uv : TEXCOORD0;  
		    //tangent空间的光线方向  
		    float3 lightDir : TEXCOORD1;  
		}; 
  
		
		v2f vert(appdata v)  
		{  
		    v2f o;  
		    o.pos = UnityObjectToClipPos(v.vertex);  
		    //这个宏为我们定义好了模型空间到切线空间的转换矩阵rotation，注意后面有个;  
		    TANGENT_SPACE_ROTATION;  
			//float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w; //副切线方向，*w是为了确定方向正确
			//float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal );//TBN确定一个面的rotation状态

		    //ObjectSpaceLightDir可以把光线方向转化到模型空间，然后通过rotation再转化到切线空间  
		    o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));  
			o.uv=v.uv;
		    return o;  
		} 

		fixed4 frag(v2f i) : SV_Target  
		{  
			//环境光
		    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;  
		    //获取法线  
		    float3 normal = UnpackNormal(tex2D(_Normal, i.uv));  
		    //光照方向  
		    float3 lightDir = normalize(i.lightDir);  
		    //罗伯特的原理:
		    fixed3 lambert = 0.5 * dot(normal, lightDir) + 0.5; 
			//加入光照,最终为颜色强度
		    fixed3 diffuse = lambert * _LightColor0.xyz + ambient;               
				
		    fixed4 color = tex2D(_MainTex, i.uv);  

		    return fixed4(diffuse* color.rgb+_Emission* color.rgb, 1.0);  
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
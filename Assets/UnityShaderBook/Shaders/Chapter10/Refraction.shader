Shader "Abel/UnityShaderBook/Chapter10/Refraction"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _RefractionColor("Refraction Color", Color) = (1, 1, 1, 1)
        _RefractionAmount("Refraction Amount", Range(0, 1)) = 1
         _RefractionRatio("Refraction Ratio", Range(0.1, 1)) = 0.5
        _Cubemap("_Cubemap", Cube) = "_Skybox"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                fixed3 worldRefr : TEXCOORD2;
                fixed3 worldViewDir : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            samplerCUBE _Cubemap;
            fixed _RefractionAmount;
            fixed4 _Color;
            fixed4 _RefractionColor;
            fixed _RefractionRatio;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractionRatio);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldPos = normalize(i.worldPos);
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 refractionColor = texCUBE(_Cubemap, i.worldRefr).rgb * _RefractionColor.rgb;
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 color = ambient + lerp(diffuse, refractionColor, _RefractionAmount) * atten;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}

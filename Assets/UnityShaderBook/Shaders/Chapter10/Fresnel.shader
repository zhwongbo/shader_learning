Shader "Abel/UnityShaderBook/Chapter10/Fresnel"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _FresnelScale("Fresnel Scale", Range(0, 1)) = 0.5
        _Cubemap("Refection Cubemap", Cube) = "_Skybox" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldViewDir : TEXCOORD1;
                fixed3 worldNormal : TEXCOORD2;
                fixed3 worldReflect : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            samplerCUBE _Cubemap;
            fixed _FresnelScale;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldReflect = reflect(-o.worldViewDir, o.worldNormal);
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldViewDir = normalize(i.worldViewDir);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldLightDir, worldNormal));

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 reflection = texCUBE(_Cubemap, i.worldReflect).rgb;

                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1- dot(worldViewDir, worldNormal), 5);

                fixed3 color = ambient + lerp(diffuse, reflection, saturate(fresnel)) * atten;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}

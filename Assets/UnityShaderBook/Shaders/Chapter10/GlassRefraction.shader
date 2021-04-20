Shader "Abel/UnityShaderBook/Chapter10/GlassRefraction"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bumpmap("Normal Map", 2D) = "bump" {}
        _Cubemap("_Environment Map", Cube) = "_Skybox"{}
        _Distortion("Distortion", Range(0, 100)) = 5
        _RefractAmount("Refract Amount", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        LOD 100

        GrabPass{"_RefractionTex"}

        Pass
        {
            Tags {"LightMode"="ForwardBase"}

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
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 iTtoW0 : TEXCOORD1;
                float4 iTtoW1 : TEXCOORD2;
                float4 iTtoW2 : TEXCOORD3;
                float4 scrPos : TEXCOORD4;
                SHADOW_COORDS(5)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bumpmap;
            float4 _Bumpmap_ST;
            samplerCUBE _Cubemap;
            float _Distortion;
            fixed _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeGrabScreenPos(o.pos);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _Bumpmap);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);//内部normalize
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);//内部normalize
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.iTtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.iTtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.iTtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.iTtoW0.w, i.iTtoW1.w, i.iTtoW2.w);
                fixed3 woldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                // 切线空间下法线
                fixed3 bump = UnpackNormal(tex2D(_Bumpmap, i.uv.zw));

                // 切线空间下偏移
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
                fixed3 refrColor = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;

                fixed3 worldNormal = normalize(half3(dot(i.iTtoW0.xyz, bump), dot(i.iTtoW1.xyz, bump), dot(i.iTtoW2.xyz, bump)));

                fixed3 reflDir = reflect(-woldViewDir, worldNormal);
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                fixed3 reflColor = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;

                fixed3 finalColor = reflColor * (1 - _RefractAmount) + refrColor * _RefractAmount;
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

Shader "Abel/UnityShaderBook/Chapter6/Diffuse-Pixel-HalfLambert"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "Queue" = "Geometry" "LightMode" = "ForwardBase"}

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal :NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed halfLambert = 0.5 * dot(i.worldNormal, worldLightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb *  halfLambert;
                fixed3 color = ambient + diffuse;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}

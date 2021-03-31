Shader "Abel/UnityShaderBook/BumpedDiffuse"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "white" {} 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                fixed3 tangentLightDir : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpMap);

                fixed3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                // TANGENT_SPACE_ROTATION   
                o.tangentLightDir = mul(rotation, ObjSpaceLightDir(v.vertex));

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                TRANSFER_SHADOW(o);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

                fixed3 tangentLightDir = normalize(i.tangentLightDir);

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                // fixed halfLambert = dot(tangentNormal, tangentLightDir) * 0.5 + 0.5;
                // fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;
                
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed3 color = ambient + diffuse * atten;

                return fixed4(color, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Tags{"LightMode"="ForwardAdd"}

            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            //#pragma multi_compile_fwdadd_fullshadows

            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                fixed3 tangentLightDir : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpMap);

                fixed3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                // TANGENT_SPACE_ROTATION   
                o.tangentLightDir = mul(rotation, ObjSpaceLightDir(v.vertex));

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                TRANSFER_SHADOW(o);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

                fixed3 tangentLightDir = normalize(i.tangentLightDir);

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                // fixed halfLambert = dot(tangentNormal, tangentLightDir) * 0.5 + 0.5;
                // fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed3 color = diffuse * atten;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}

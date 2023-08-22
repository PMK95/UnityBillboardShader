Shader "BillboardSimple" 
{
   Properties 
   {
      _MainTex ("Texture", 2D) = "white" {}
      _Color ("Color", Color) = (1,1,1,1)
   }
   SubShader 
   {
      Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
      Pass 
      {   
         CGPROGRAM

         #pragma vertex vert  
         #pragma fragment frag
      
         uniform sampler2D _MainTex;        
         uniform float4 _MainTex_ST;
         uniform float4 _Color;
         
         struct vertexInput
         {
            float4 vertex : POSITION;
            float4 tex : TEXCOORD0;
         };
         
         struct vertexOutput
         {
            float4 pos : SV_POSITION;
            float4 tex : TEXCOORD0;
         };
         
         float3 GetObjectScale(float4x4 _matrix)
         {
             return float3(length(_matrix[0].xyz), length(_matrix[1].xyz), length(_matrix[2].xyz));
         }

         float4 GetTranslation(float4x4 _matrix)
         {
             return float4(unity_MatrixMV._m03,unity_MatrixMV._m13,unity_MatrixMV._m23,unity_MatrixMV._m33);
         }

         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
            float4 pos = input.vertex;
            output.pos = mul(UNITY_MATRIX_P, GetTranslation(unity_MatrixMV)+ (pos * float4(GetObjectScale(unity_ObjectToWorld), 1.0)));
            output.tex = input.tex;
            output.tex.xy = input.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw;
            return output;
         }

         float4 frag(vertexOutput input) : COLOR
         {
            return tex2D(_MainTex, float2(input.tex.xy))*_Color;   
         }

         ENDCG
      }
   }
}
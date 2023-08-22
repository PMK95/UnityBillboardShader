Shader "Billboard" 
{
   Properties 
   {
      _MainTex ("Texture", 2D) = "white" {}
      _Color ("Color", Color) = (1,1,1,1)

      [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Z Test", Float) = 4
      [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 1
      [Enum(UnityEngine.Rendering.BlendMode)] _SrcFactor("Src Factor", Float) = 5
      [Enum(UnityEngine.Rendering.BlendMode)] _DstFactor("Dst Factor", Float) = 10
      
      [Header(BillboardOptions)]
      [Space]
      _RotationOffsetXYZ ("RotationOffsetXYZ", Vector) = (0,0,0,0)
      _LocalPositionOffsetXYZ ("LocalPositionOffsetXYZ", Vector) = (0,0,0,0)
      _WorldPositionOffsetXYZ ("WorldPositionOffsetXYZ", Vector) = (0,0,0,0)
      [Toggle] _FixedScale ("FixedScale", Float) = 0
      _FixedScaleXYZ ("FixedScaleXYZ", Vector) = (1,1,1,0)
   }
   SubShader 
   {
      Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
      ZTest  [_ZTest]
      ZWrite [_ZWrite]
      Blend  [_SrcFactor] [_DstFactor]

      Pass 
      {   
         CGPROGRAM

         #pragma vertex vert  
         #pragma fragment frag
      
         uniform sampler2D _MainTex;        
         uniform float4 _MainTex_ST;
         uniform float4 _Color;
         uniform float3 _RotationOffsetXYZ;
         uniform float3 _LocalPositionOffsetXYZ;
         uniform float3 _WorldPositionOffsetXYZ;
         uniform float _FixedScale;
         uniform float3 _FixedScaleXYZ;
         
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
         
         float4 RotateAroundX(float4 vertex, float radian)
         {
             float sina, cosa;
             sincos(radian, sina, cosa);

             float4x4 m;

             m[0] = float4(1, 0, 0, 0);
             m[1] = float4(0, cosa, -sina, 0);
             m[2] = float4(0, sina, cosa, 0);
             m[3] = float4(0, 0, 0, 1);

             return mul(m, vertex);
         }

         float4 RotateAroundY(float4 vertex, float radian)
         {
             float sina, cosa;
             sincos(radian, sina, cosa);

             float4x4 m;

             m[0] = float4(cosa, 0, sina, 0);
             m[1] = float4(0, 1, 0, 0);
             m[2] = float4(-sina, 0, cosa, 0);
             m[3] = float4(0, 0, 0, 1);

             return mul(m, vertex);
         }

         float4 RotateAroundZ(float4 vertex, float radian)
         {
             float sina, cosa;
             sincos(radian, sina, cosa);

             float4x4 m;

             m[0] = float4(cosa, -sina, 0, 0);
             m[1] = float4(sina, cosa, 0, 0);
             m[2] = float4(0, 0, 1, 0);
             m[3] = float4(0, 0, 0, 1);

             return mul(m, vertex);
         }
         
         float3 GetObjectScale(float4x4 _matrix)
         {
             return float3(length(_matrix[0].xyz), length(_matrix[1].xyz), length(_matrix[2].xyz));
         }
         
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
            float3 objectScale = GetObjectScale(unity_ObjectToWorld);
            objectScale = lerp(objectScale, _FixedScaleXYZ.xyz, _FixedScale);
            
            float4 pos = input.vertex;
            pos = RotateAroundX(pos, radians(_RotationOffsetXYZ.x));
            pos = RotateAroundY(pos, radians(_RotationOffsetXYZ.y));
            pos = RotateAroundZ(pos, radians(_RotationOffsetXYZ.z));
            
            output.pos = mul(UNITY_MATRIX_P, 
              mul(unity_MatrixMV,
                 float4(_LocalPositionOffsetXYZ, 1.0))
              + float4(pos + _WorldPositionOffsetXYZ, 1)
              * float4(objectScale, 1.0));
            output.tex = input.tex;
            output.tex.xy = input.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw;
            return output;
         }

         float4 frag(vertexOutput input) : COLOR
         {
            return tex2D(_MainTex, float2(input.tex.xy)) * _Color;   
         }

         ENDCG
      }
   }
}
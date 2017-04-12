Shader "Custom/Distortion" {

    Properties {
		_Color ("Color (RGBA)", Color) = (1,1,1,1)
		[NoScaleOffset] _MainTex ("Texture (RGBA)", 2D) = "white" {}
        _DistortionTex ("Distortion Texture (RG)", 2D) = "bump" {}
        _DistortionStrength ("Distortion Strength", Float) = 0.05
	}

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector" = "True" "PreviewType"="Plane" }

        //subshaders are used for compatibility. If the first subshader isn't compatible, it'll attempt to use the one below it.
        Pass
        {

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Lighting Off

            CGPROGRAM
                //begin CG block

                #pragma vertex vert
                //we will use a vertex function, named "vert". vert_img is defined in UnityCG.cginc

                #pragma fragment frag
                //we will use a fragment function, named "frag"
            
                #include "UnityCG.cginc"
                //use a CGInclude file defining several useful functions, including our vertex function
            
                //declare our external properties
                uniform fixed4 _Color;
                uniform sampler2D _MainTex;
                uniform sampler2D _DistortionTex;
                uniform float4 _DistortionTex_ST; //scale and offset from inspector
                uniform fixed _DistortionStrength;

                //declare input and output structs for vertex and fragment functions

                struct appdata
                {
                    float4 vertex : POSITION;
                    half2 texcoord : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    half2 uv : TEXCOORD0;
                    half4 shiftedUvs : TEXCOORD1;
                };

                v2f vert( appdata v )
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos (v.vertex);
                    o.uv = v.texcoord;
                    o.shiftedUvs.xy = TRANSFORM_TEX(v.texcoord, _DistortionTex) - _Time.xx; //first set of time-shifted displacement UVs
                    o.shiftedUvs.zw = TRANSFORM_TEX(v.texcoord, _DistortionTex) + float2(0.5 - _Time.x, 0.5 + _Time.x); //second set of time-shifted displacement UVs

                    return o;
                }

                fixed4 frag (v2f i) : SV_Target
                {
                    // : SV_Target semantic marks the return value as the color of the fragment.

                    fixed4 distortionValues;
                    distortionValues.xy = tex2D(_DistortionTex, i.shiftedUvs.xy).rg;
                    distortionValues.zw = tex2D(_DistortionTex, i.shiftedUvs.zw).rg;
                    //sample the distortion texture for both sets of distortion UVs

                    distortionValues *= _DistortionStrength;
                    //scale the sampled distortion values

                    fixed4 textureCol = tex2D(_MainTex, i.uv + distortionValues.xy + distortionValues.zw);
                    //sample from the current texture at a distorted UV

                    return _Color * textureCol; //return tinted texture color
                }
            ENDCG
        }
    }
    Fallback "Diffuse" //If all of our subshaders aren't compatible, use subshaders from a different shader file
}
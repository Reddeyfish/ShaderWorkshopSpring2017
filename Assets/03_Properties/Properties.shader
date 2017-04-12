Shader "Custom/Properties" {

    Properties {
		_Color ("Color (RGBA)", Color) = (1,1,1,1)
		_MainTex ("Texture (RGBA)", 2D) = "white" {}
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

                #pragma vertex vert_img
                //we will use a vertex function, named "vert_img". vert_img is defined in UnityCG.cginc

                #pragma fragment frag
                //we will use a fragment function, named "frag"
            
                #include "UnityCG.cginc"
                //use a CGInclude file defining several useful functions, including our vertex function
            
                //declare our external properties
                uniform fixed4 _Color;
                uniform sampler2D _MainTex;

                fixed4 frag (v2f_img i) : SV_Target
                {
                    //v2f_img defined in UnityCG.cginc, and is the output struct of our vertex function
                    // : SV_Target semantic marks the return value as the color of the fragment.

                    fixed4 textureCol = tex2D(_MainTex, i.uv);
                    //sample from the current texture
                    return _Color * textureCol; //return tinted texture color
                }
            ENDCG
        }
    }
    Fallback "Diffuse" //If all of our subshaders aren't compatible, use subshaders from a different shader file
}
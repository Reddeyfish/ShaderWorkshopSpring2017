Shader "Completed/Dissolve" {

    Properties {
		_Color ("Color (RGBA)", Color) = (1,1,1,1)
		[NoScaleOffset] _MainTex ("Texture (RGBA)", 2D) = "white" {}
		[NoScaleOffset] _ThresholdMap ("ThresholdMap (Greyscale)", 2D) = "white" {}
        [PerRendererData] _AlphaThreshold ("Transparency Threshold", Range(0, 1)) = 0.5
        [PerRendererData] _ColorOffset ("Solid Color Offset (from Transparency)", Range(0, 0.5)) = 0.1
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
                uniform sampler2D _ThresholdMap;
                uniform fixed _AlphaThreshold;
                uniform fixed _ColorOffset;

                fixed4 frag (v2f_img i) : SV_Target
                {
                    fixed testValue = tex2D(_ThresholdMap, i.uv).r;
                    //sample from threshold map. It is greyscale, so we only need one value

                    /*
                    if(testValue < _AlphaThreshold) {
                        return fixed4(0, 0, 0, 0);
                    } else {
                        fixed4 textureCol = tex2D(_MainTex, i.uv);
                        if(testValue < _AlphaThreshold + _ColorOffset) {
                            return fixed4(_Color.rgb, _Color.a * textureCol.a);
                        } else {
                            return textureCol;
                        }
                    }
                    */
                    ///*
                    fixed4 textureCol = tex2D(_MainTex, i.uv);
                    //sample from the current texture

                    fixed alphaThresholdPassed = step(_AlphaThreshold, testValue);
                    fixed colorThresholdPassed = step(_AlphaThreshold + _ColorOffset, testValue);
                    //these values will be one if the test value is over the threshold, zero otherwise.

                    fixed4 solidColor = fixed4(_Color.rgb, _Color.a * textureCol.a);
                    //the solid color to use if the color threshold was failed. Multiplying by texture alpha ensures that the color is transparent where the texture is transparent

                    fixed4 outputColor = lerp(solidColor, textureCol, colorThresholdPassed);
                    //the texture color if threshold map value passes the color threshold, the solid color otherwise



                    outputColor.a *= alphaThresholdPassed;
                    //alpha component will remain unchanged if threshold map passes the alpha threshold, will be set to zero otherwise.

                    return outputColor;
                    //*/
                }
            ENDCG
        }
    }
    Fallback "Diffuse" //If all of our subshaders aren't compatible, use subshaders from a different shader file
}
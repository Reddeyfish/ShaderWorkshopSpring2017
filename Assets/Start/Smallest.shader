Shader "Custom/Smallest" {

    SubShader
    {
        //subshaders are used for compatibility. If the first subshader isn't compatible, it'll attempt to use the one below it.
        Pass
        {
            CGPROGRAM
                //begin CG block

                #pragma vertex vert_img
                //we will use a vertex function, named "vert_img". vert_img is defined in UnityCG.cginc

                #pragma fragment frag
                //we will use a fragment function, named "frag"
            
                #include "UnityCG.cginc"
                //use a CGInclude file defining several useful functions, including our vertex function
            
                fixed4 frag (v2f_img i) : SV_Target
                {
                    //v2f_img defined in UnityCG.cginc, and is the output struct of our vertex function
                    // : SV_Target semantic marks the return value as the color of the fragment.

                    fixed4 col = fixed4(1, 0, 0, 0.5);
                    return col;
                }
            ENDCG
        }
    }
    Fallback "Diffuse" //If all of our subshaders aren't compatible, use subshaders from a different shader file
}
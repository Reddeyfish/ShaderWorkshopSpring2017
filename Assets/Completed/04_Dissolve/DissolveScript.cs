using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;

namespace Completed {

    [RequireComponent(typeof(Renderer))]
    public class DissolveScript : MonoBehaviour {

        Renderer rend;

        [SerializeField]
        protected float animationDuration = 1.0f;

        void Start() {
            rend = GetComponent<Renderer>();
        }

        void Update() {
            MaterialPropertyBlock instancedData = new MaterialPropertyBlock();
            float alphaThreshold = (Time.time / animationDuration) % 1;
            instancedData.SetFloat("_AlphaThreshold", alphaThreshold);

            float colorOffset = Mathf.Min(alphaThreshold, 1 - alphaThreshold); //value is the distance to the nearest whole number
            colorOffset /= 4; //scale the output range from [0..0.5] to [0..0.125]
            instancedData.SetFloat("_ColorOffset", colorOffset);

            rend.SetPropertyBlock(instancedData);
        }
    }
}

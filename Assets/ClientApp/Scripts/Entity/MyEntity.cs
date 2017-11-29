using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;
public class MyEntity : EntityLogic {


    protected internal override void OnInit(object userData)
    {
        Animator[] anims = gameObject.GetComponentsInChildren<Animator>();

        for (int i = 0; i < anims.Length; ++i)
        {
            anims[i].gameObject.AddComponent<AnimatorEvent>();
        }
    }
}

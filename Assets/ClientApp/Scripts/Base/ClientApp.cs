using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;

public partial class ClientApp : MonoBehaviour
{

    private void Start()
    {
        InitGameComponents();
        InitGameComponentCustom();
        InitGameComponentsExtension();
        GameObject.DontDestroyOnLoad(this);
    }
}


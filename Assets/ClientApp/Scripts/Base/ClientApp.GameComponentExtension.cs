using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GameComponentExtension;

public partial class ClientApp
{
    void InitGameComponentsExtension()
    {
        ClientApp.WebRequest.InitializationExtension();
    }
}

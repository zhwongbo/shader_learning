using System;
using UnityEditor;
using UnityEngine;

public class RenderCubemapWizard : ScriptableWizard
{
    public Transform renderFromPosition;
    public Cubemap cubemap;
    
    [MenuItem("AbelEditor/Render into Cubemap")]
    static void RenderCubemap()
    {
        DisplayWizard<RenderCubemapWizard>("Render cubemap", "Render!");
    }

    private void OnWizardUpdate()
    {
        helpString = "Select transform to render from and cubemap to render into";
        isValid = (renderFromPosition != null) && (cubemap != null);
    }

    private void OnWizardCreate()
    {
        GameObject go = new GameObject("CubemapCamera");
        Camera camera = go.AddComponent<Camera>();
        go.transform.position = renderFromPosition.position;
        camera.RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }
}
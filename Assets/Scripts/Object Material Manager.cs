using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ObjectMaterialManager : MonoBehaviour
{
    [SerializeField]
    private Renderer meshObject;

    [SerializeField]
    private Material loadingMaterial;

    private Material originalMaterial;
    private Material modelMaterial;

    public void Awake()
    {
        modelMaterial = meshObject.material;
    }

    public void SetPending()
    {
        modelMaterial = meshObject.material;
        meshObject.material = loadingMaterial;
    }

    public void SetFinished()
    {
        meshObject.material = modelMaterial;
    }

    public void SetMaterial(Material material)
    {
        //AssetDatabase.GetAssetPath()
        modelMaterial = material;
    }

    public void setMaterialImmediate(Material material)
    {
        modelMaterial = material;
        meshObject.material = material;
    }

    public void RevertToOriginalMaterial()
    {
        meshObject.material = originalMaterial;
    }

}

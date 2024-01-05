using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Object Material Variant")]
public class ObjectMaterialVariant : ScriptableObject
{
    public List<string> names;
    public List<Sprite> uis;
    public List<Material> materials;
    // Start is called before the first frame update
    public Material GetMaterialFromName(string name)
    {
        return materials[names.IndexOf(name)];
    }

    public Sprite GetUITextureFromName(string name)
    {
        return uis[names.IndexOf(name)];
    }
}

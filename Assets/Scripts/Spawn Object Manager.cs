using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using UnityEngine.UI;

public class SpawnObjectManager : MonoBehaviour
{
    [SerializeField]
    private Camera userCamera;

    [SerializeField]
    private GameObject spawnPrefab;

    [SerializeField]
    private GameObject arSessionObject;

    [SerializeField]
    private ObjectMaterialVariant materialVariants;

    [SerializeField]
    private GameObject objectGeneratorBar;

    [SerializeField]
    private GameObject buttonPrefab;

    [SerializeField]
    private GameObject inventoryButton;

    [SerializeField]
    private GameObject editBar;

    private ARRaycastManager raycastManager;
    private ARPlaneManager planeManager;

    private List<ARRaycastHit> hits = new List<ARRaycastHit>();
    private List<GameObject> spawnedObjects = new List<GameObject>();

    private Vector2 rayCastScreenLocation;

    private bool spawnPrefabActivated = false;

    private ARRaycast globalRaycast;
    private GameObject currentObject;

    private float rotationOffset;

    private bool editUI = false;

    private bool editMode = false;
    // Start is called before the first frame update
    void Awake()
    {
        raycastManager = arSessionObject.GetComponent<ARRaycastManager>();
        planeManager = arSessionObject.GetComponent<ARPlaneManager>();
        rayCastScreenLocation = new Vector2(Screen.width / 2, Screen.height / 2);
        SetVariantUI();
    }

    // Update is called once per frame
    void Update()
    {
        if (spawnPrefabActivated)
        {

            if (raycastManager.Raycast(rayCastScreenLocation, hits, TrackableType.PlaneWithinPolygon))
            {

                Pose hitPose = hits[0].pose;

                var objectPosition = hitPose.position;
                var objectRotation = Quaternion.LookRotation(userCamera.transform.position - objectPosition).eulerAngles;
                //Debug.Log("Found location to be " + objectPosition.ToString());

                objectRotation.y += rotationOffset;

                var rotationResult = new Vector3(0,objectRotation.y,0);

                currentObject.transform.position = objectPosition;
                currentObject.transform.rotation = Quaternion.Euler(rotationResult);

            }
        }

    }

    public void startEditMode() { editMode = true; }

    public void endEditMode() { editMode = false; }

    public bool GetEditMode() { return spawnPrefabActivated; }

    public void SetRotation(Slider Rotation) { rotationOffset = Rotation.value * 360 - 180; }

    public void SetSize(Slider objSize) { currentObject.transform.localScale = new Vector3(objSize.value, objSize.value, objSize.value); }

    public void StartPlacement()
    {
        if (spawnPrefabActivated) //As we have not finished spawning a prefab, we will first delete the old one
        {

        } else //Only when we are not spawning right now
        {
            
            Debug.Log("Begin Spawning Object");
            
            currentObject = Instantiate(spawnPrefab);
            LeanTween.scale(currentObject, Vector3.zero, 0.0f);
            
            spawnedObjects.Add(currentObject);
            currentObject.GetComponent<ObjectMaterialManager>().SetPending();
            LeanTween.scale(currentObject, new Vector3(0.6f,0.6f,0.6f), 1.0f).setEaseOutBounce().setRepeat(1).setOnComplete(()=>Debug.Log("Repeating"));
            //LeanTween.alpha(currentObject, 0.5f, 0.5f);
            //globalRaycast = raycastManager.AddRaycast(new Vector2(Screen.width / 2, Screen.height / 2), 0);
            spawnPrefabActivated = true;
        }
    }

    public void OnPlaceSpawnObject()
    {
        //LeanTween.alpha(currentObject, 1.0f, 0.5f);
        spawnPrefabActivated = false;
        editMode = false;
        //raycastManager.RemoveRaycast(globalRaycast);
        currentObject.GetComponent<ObjectMaterialManager>().SetFinished();
        currentObject = null;
        DisplayEditUI();
    }

    public void SetMaterialVariant(string variantName)
    {
        Debug.Log("Setting Material Variant as " + variantName);
        if (!editMode)
        {
            StartPlacement(); //Only Place If Not Edit Mode
            currentObject.GetComponent<ObjectMaterialManager>().SetMaterial(materialVariants.GetMaterialFromName(variantName));
        }
        else
        {
            currentObject.GetComponent<ObjectMaterialManager>().setMaterialImmediate(materialVariants.GetMaterialFromName(variantName));
        }
    }

    private void SetVariantUI()
    {
        LeanTween.alpha(editBar, 0.0f, 0.0f);
        LeanTween.moveX(editBar, 40.0f - Screen.width, 0.0f);
        LeanTween.alpha(objectGeneratorBar.transform.parent.parent.gameObject, 0.0f, 0.0f);
        LeanTween.moveX(objectGeneratorBar.transform.parent.parent.gameObject, 40.0f + Screen.width, 0.0f);
        for (int i = 0; i < materialVariants.names.Count; i++)
        {
            var newButton = Instantiate(buttonPrefab);
            newButton.transform.SetParent(objectGeneratorBar.transform);
            newButton.transform.GetChild(0).GetChild(0).gameObject.GetComponent<Image>().sprite = materialVariants.uis[i];
            var name = materialVariants.names[i];
            Debug.Log("Adding name of " + name);
            newButton.GetComponent<Button>().onClick.AddListener(() => SetMaterialVariant(name));
        }
    }

    public void DisplayEditUI()
    {
        if (editUI)
        {
            var rotationSlider = editBar.transform.GetChild(1).GetChild(1).GetComponent<Slider>();
            var scaleSlider = editBar.transform.GetChild(0).GetChild(1).GetComponent<Slider>();
            LeanTween.alpha(editBar, 0.0f, 0.5f).setEaseOutCubic().setOnComplete(() => rotationSlider.value = 0.5f);
            LeanTween.moveX(editBar, 40.0f - Screen.width, 0.3f).setEaseOutCubic().setOnComplete(()=>scaleSlider.value = 0.6f);
            LeanTween.moveX(objectGeneratorBar.transform.parent.parent.gameObject, 40.0f + Screen.width, 0.5f).setEaseOutCubic();
            LeanTween.alpha(objectGeneratorBar.transform.parent.parent.gameObject, 0.0f, 0.5f).setEaseOutCubic();
            LeanTween.moveY(inventoryButton, 320.0f, 0.5f).setEaseOutCubic().setDelay(0.2f);
            editUI = false;
        }
        else
        {
            LeanTween.alpha(editBar, 1.0f, 0.5f).setEaseOutCubic();
            LeanTween.moveX(editBar, 40.0f, 0.5f).setEaseOutCubic();
            LeanTween.moveY(inventoryButton, 560.0f, 0.5f).setEaseOutCubic();
            LeanTween.moveX(objectGeneratorBar.transform.parent.parent.gameObject, 40.0f, 0.5f).setDelay(0.3f).setEaseOutCubic();
            LeanTween.alpha(objectGeneratorBar.transform.parent.parent.gameObject, 1.0f, 0.5f).setDelay(0.3f).setEaseOutCubic();
            editUI = true;
        }
    }

    public void SetEditObject(GameObject objectToSet)
    {
        currentObject = objectToSet;
        editMode = true;
        spawnPrefabActivated = true;
        DisplayEditUI();
    }

    public void resetToFacingDirection()
    {
        rotationOffset = 0;
    }
}
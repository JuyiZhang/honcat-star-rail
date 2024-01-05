using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using EnhancedTouch = UnityEngine.InputSystem.EnhancedTouch;

public class ObjectInteractionManager : MonoBehaviour
{
    //Timer for click execution
    float timerTime;
    bool timerActivated = false;
    Vector2 touchDownPosition;
    GameObject targetObject;

    bool editLock = false;

    [SerializeField]
    private Canvas mainCanvas;

    [SerializeField]
    private GameObject interactionPrefab;

    private GameObject currentInteractionGameObject;
    private SpawnObjectManager objectManager;

    private void Awake()
    {
        OnEnable();
        objectManager = GetComponent<SpawnObjectManager>();
    }

    private void Update()
    {
        if (timerActivated)
        {
            timerTime -= Time.deltaTime;
            if(timerTime <= 0)
            {
                timerActivated = false; //Consider as long press
                if (!editLock && !objectManager.GetEditMode())
                    InitInteraction(touchDownPosition, targetObject); //Only init interaction if no editlock
            }
        }
    }

    private void OnEnable()
    {
        EnhancedTouch.TouchSimulation.Enable();
        EnhancedTouch.EnhancedTouchSupport.Enable();
        EnhancedTouch.Touch.onFingerDown += OnBeginTouch;
        EnhancedTouch.Touch.onFingerUp += OnEndTouch;
    }

    private void OnDisable()
    {
        EnhancedTouch.TouchSimulation.Enable();
        EnhancedTouch.EnhancedTouchSupport.Enable();
        EnhancedTouch.Touch.onFingerDown -= OnBeginTouch;
        EnhancedTouch.Touch.onFingerUp -= OnEndTouch;
    }

    private void OnBeginTouch(EnhancedTouch.Finger finger)
    {
        if (finger.index != 0) return;
        timerActivated = false;
        timerTime = 1.0f;
        Ray ray = Camera.main.ScreenPointToRay(finger.currentTouch.screenPosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit))
        {
            targetObject = hit.transform.gameObject;
            timerActivated = true;
            touchDownPosition = finger.currentTouch.screenPosition;
        }
        
        
    }

    private void OnEndTouch(EnhancedTouch.Finger finger)
    {
        if (timerActivated && timerTime > 0) //short press
        {
            timerActivated = false;
            if (currentInteractionGameObject != null)
                DestroyObject(null, currentInteractionGameObject);
            InteractWithObject(targetObject, null);
        }
    }

    private void InteractWithObject(GameObject interactObject, GameObject canvasObject)
    {

        Animator objectAnimationController;
        if (interactObject.TryGetComponent(out objectAnimationController))
        {
            objectAnimationController.SetTrigger("BeginConversation");
        } else
        {
            Debug.Log("Wrong Object Tapped");
            return;
        }
        var cakeAudio = Resources.Load<AudioClip>("Audio/RuanMadeCake_0" + UnityEngine.Random.Range(0, 5).ToString());

        if (cakeAudio == null)
        {
            Debug.Log("Failed to Load Audio");
        } else
        {
            interactObject.GetComponent<AudioSource>().clip = cakeAudio;
        }
        interactObject.GetComponent<AudioSource>().Play();
        
        if (canvasObject != null)
        {
            LeanTween.scale(canvasObject, Vector3.zero, 1.0f).setEaseInCubic().setOnComplete(() => GameObject.Destroy(canvasObject));
        }
        editLock = false;
    }

    private void DestroyObject(GameObject objectToDestroy, GameObject canvasObject)
    {
        timerActivated = false;
        objectToDestroy.GetComponent<AudioSource>().Stop();
        if (objectToDestroy != null)
            LeanTween.scale(objectToDestroy, Vector3.zero, 1.0f).setEaseInCubic().setOnComplete(()=>GameObject.Destroy(objectToDestroy));
        if (canvasObject != null)
        {
            LeanTween.scale(canvasObject, Vector3.zero, 1.0f).setEaseInCubic().setOnComplete(() => GameObject.Destroy(canvasObject));
        }
        editLock = false;
    }

    private void InitInteraction(Vector2 initPosition, GameObject objectHit)
    {
        Debug.Log("Long Press Detected");
        editLock = true;
        currentInteractionGameObject = Instantiate(interactionPrefab);
        LeanTween.alpha(currentInteractionGameObject, 0.0f, 0.0f);
        currentInteractionGameObject.transform.SetParent(mainCanvas.transform);
        LeanTween.move(currentInteractionGameObject, initPosition, 0.0f);
        LeanTween.alpha(currentInteractionGameObject, 1.0f, 0.5f);
        currentInteractionGameObject.transform.GetChild(0).GetChild(0).gameObject.GetComponent<Button>().onClick.AddListener(() => InteractWithObject(objectHit, currentInteractionGameObject));
        currentInteractionGameObject.transform.GetChild(0).GetChild(1).gameObject.GetComponent<Button>().onClick.AddListener(() => BeginEditObject(objectHit, currentInteractionGameObject));
        currentInteractionGameObject.transform.GetChild(0).GetChild(2).gameObject.GetComponent<Button>().onClick.AddListener(() => DestroyObject(objectHit, currentInteractionGameObject));
    }

    private void BeginEditObject(GameObject editObject, GameObject canvasObject)
    {
        objectManager.SetEditObject(editObject);
        if (canvasObject != null)
        {
            LeanTween.scale(canvasObject, Vector3.zero, 1.0f).setEaseInCubic().setOnComplete(() => GameObject.Destroy(canvasObject));
        }
        editLock = false;
    }
}

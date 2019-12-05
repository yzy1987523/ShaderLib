/*文件名：MaskCtrl_Cull.cs
 * 作者：YZY
 * 说明：Cull的遮罩控制器
 * 上次修改时间：2019/12/4 
 * */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class MaskCtrl_Cull : MonoBehaviour
{
    public MaskType maskType=MaskType.Plane;
    public float radius;
    List<Material> mats = new List<Material>();
    Renderer[] renderers;
    private void OnEnable()
    {
        renderers = FindObjectsOfType<Renderer>();
        CollectMaterials();
    }
    void Update()
    {
        for (int i = 0; i < mats.Count; i++)
        {
            SetMaterial(mats[i]);
        }
        if (Application.isPlaying)
        {
            if (maskType == MaskType.Plane)
            {
                transform.Rotate(Vector3.up,Time.deltaTime*100);
            }
            else if(maskType==MaskType.Sphere)
            {
                radius = Mathf.PingPong(Time.realtimeSinceStartup * 2, 1);
            }
        }
    }
    void SetMaterial(Material _mat)
    {
        if (maskType == MaskType.Plane)
        {
            _mat.DisableKeyword("MASK_SPHERE");
            _mat.EnableKeyword("MASK_PLANE");
            _mat.SetVector("_CutAxis", transform.forward);
            _mat.SetVector("_CutCenter", transform.position);
        }
        else if (maskType == MaskType.Sphere)
        {
            _mat.DisableKeyword("MASK_PLANE");
            _mat.EnableKeyword("MASK_SPHERE");
            _mat.SetVector("_CutCenter", transform.position);
            _mat.SetFloat("_CutThreshold", radius);
        }
        else
        {
            _mat.DisableKeyword("MASK_PLANE");
            _mat.DisableKeyword("MASK_SPHERE");
        }
       
    }

    void CollectMaterials()
    {   
        for (int i = 0; i < renderers.Length; i++)
        {
            for (int j = 0; j < renderers[i].sharedMaterials.Length; j++)
            {
                if (!mats.Contains(renderers[i].sharedMaterials[j]))
                    mats.Add(renderers[i].sharedMaterials[j]);
            }
        }
    }
    private void OnDrawGizmos()
    {
        if (maskType == MaskType.Plane)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawRay(transform.position,transform.forward);
        }
        else if (maskType == MaskType.Sphere)
        {
            Gizmos.color = Color.blue;
            Gizmos.DrawWireSphere(transform.position, radius);
        }
        
    }
    public enum MaskType
    {
        None,
        Plane,
        Sphere,
    }
}

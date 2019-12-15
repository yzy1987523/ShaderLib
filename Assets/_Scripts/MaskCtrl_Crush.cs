/*文件名：MaskCtrl_Crush.cs
 * 作者：YZY
 * 说明：Crush的遮罩控制器
 * 上次修改时间：2019/12/15
 * */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class MaskCtrl_Crush : MonoBehaviour
{
    public float intensity; 
    List<Material> mats = new List<Material>();
    Renderer[] renderers;
    public float height = 1;
    bool changeDir;
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
    }
    void SetMaterial(Material _mat)
    {

            _mat.SetVector("_CutAxis", transform.forward);
            _mat.SetVector("_CutCenter", transform.position);
            _mat.SetFloat("_CutThreshold", intensity);
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
            Gizmos.color = Color.red;
            Gizmos.DrawRay(transform.position,transform.forward);        
    }
}

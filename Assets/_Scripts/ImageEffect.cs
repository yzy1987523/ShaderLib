using UnityEngine;
[ExecuteInEditMode]
public class ImageEffect : MonoBehaviour
{
    public Material mat;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //Graphics.Blit(source, rTex);//rTex可以提取出来

        if (mat == null) Graphics.Blit(source, destination);//不用屏幕特效【注意，一旦用了OnRenderImage函数，如果不用屏幕特效，就要写这一行，否则就会呈黑色】

        if (mat != null) Graphics.Blit(source, destination, mat);//应用屏幕特效

    }
}
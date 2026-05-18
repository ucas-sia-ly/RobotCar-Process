import os
import glob
from tqdm import tqdm
from PIL import Image
# 导入官方 SDK 里的 load_image 函数
from image import load_image 

def batch_convert_robotcar(input_dir, output_dir):
    """
    批量将 RobotCar 的 Bayer 原始图转换为真彩色 RGB 图
    """
    os.makedirs(output_dir, exist_ok=True)
    
    # 查找输入目录下所有的 png 图片
    img_paths = glob.glob(os.path.join(input_dir, "*.png")) 
    print(f"找到 {len(img_paths)} 张图片准备转换...")
    
    for path in tqdm(img_paths):
        try:
            # 1. 调用官方函数：它会自动读取、解马赛克，并返回 uint8 类型的 numpy 数组
            rgb_array = load_image(path, debayer=True)
            
            # 2. 将 numpy 数组转回为正常的图片对象
            rgb_img = Image.fromarray(rgb_array)
            
            # 3. 保存到输出目录
            basename = os.path.basename(path)
            out_path = os.path.join(output_dir, basename)
            rgb_img.save(out_path)
            
        except AttributeError as e:
            # 捕获正则匹配失败的错误
            print(f"\n跳过 {path}: 路径中未检测到相机名称关键字。")
        except Exception as e:
            print(f"\n处理 {path} 时出错: {e}")

if __name__ == "__main__":
    # ⚠️ 请修改下面的路径为你自己的文件夹路径
    # 注意：输入路径(包含其上级目录)中，必须包含单词 "stereo" 
    input_main="/home/admin123/git/RobotCar"
    output_main="/home/admin123/git/RobotCar_RGB/night"
    time=[""]
    for i in time:
        INPUT_FOLDER = os.path.join(input_main,i,"stereo/centre")
        OUTPUT_FOLDER = os.path.join(output_main,i,"stereo/centre")
        
        batch_convert_robotcar(INPUT_FOLDER, OUTPUT_FOLDER)

    print("全部转换完成！")
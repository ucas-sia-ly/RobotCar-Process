仓库参考了[RobotCarDataset-Scraper](https://github.com/mttgdd/RobotCarDataset-Scraper)和[robotcar-dataset-sdk](https://github.com/ori-mrg/robotcar-dataset-sdk)的内容。核心作用是从[Oxford RobotCar Dataset](https://robotcar-dataset.robots.ox.ac.uk/)的公开站点批量抓取数据、把原始 Bayer 图像转换为普通彩色图像。

1. [scrape_mrgdatashare.py](scrape_mrgdatashare.py)：主下载脚本。负责登录、按 run 和 sensor 过滤、下载 tar、解压、清理临时文件。
2. [get_datasets.py](get_datasets.py)：从 RobotCar 数据集网页抓取完整的数据集目录，生成 [datasets.csv](datasets.csv)。
3. [datasets.csv](datasets.csv)：下载清单文件。每一行代表一个 run，后面跟着该 run 可下载的传感器/文件类型。
4. [my_runs.txt](my_runs.txt)：当前仓库里使用的 run 列表示例。
5. [auto_download.sh](auto_download.sh)：批量下载示例脚本，带有重试、跳过已完成 run、断点继续等逻辑。
6. [process_dataset.py](process_dataset.py)：批量把下载后的原始 Bayer 图像转换为彩色图，并尽量保留目录结构。
7. [image.py](image.py)：提供官方风格的图像读取和去马赛克函数，转换脚本会调用它。

### 安装依赖

下载脚本本身依赖的包在 [requirements.txt](requirements.txt) 中列了出来。`pip install -r requirements.txt`

下载数据前，你需要能登录 Oxford RobotCar 的 mrgdatashare 站点注册账号。

### 基本下载流程

1. 先生成 [datasets.csv](datasets.csv)。
2. 再准备一个 run 列表文件，比如 [my_runs.txt](my_runs.txt) 或你自己的文本文件。
3. 最后运行 [scrape_mrgdatashare.py](scrape_mrgdatashare.py) 下载并解压。


如果你当前仓库里的 [datasets.csv](datasets.csv) 不是最新的，可以运行：`python get_datasets.py`。这个脚本会访问数据集页面，抓取所有 run 的列表，再进入每个 run 页面找出可下载的 tar 文件类型，最终重新写出一个新的 [datasets.csv](datasets.csv)。


如果你想只下载部分 run，把 run 名称一行一个写进文本文件 [my_runs.txt](my_runs.txt) 即可。

最完整的命令形态如下：

```bash
python scrape_mrgdatashare.py \
  --downloads_dir /path/to/RobotCar \
  --datasets_file datasets.csv \
  --choice_runs_file my_runs.txt \
  --choice_sensors stereo_centre,gps \
  --username YOUR_USERNAME \
  --password YOUR_PASSWORD
```

1. 读取 [datasets.csv](datasets.csv)。
2. 只筛选 [my_runs.txt](my_runs.txt) 里列出的 run。
3. 只下载 `stereo_centre` 和 `gps` 相关文件。
4. 登录站点、下载 tar 文件、自动解压。
5. 下载成功后删除对应 tar 文件，只保留解压结果。

但国内下载总是不稳定，[auto_download.sh](auto_download.sh) 调用 [scrape_mrgdatashare.py](scrape_mrgdatashare.py) 反复重试，直到成功或你手动中断。每一个下载成功后创建 `run_name.done` 标记文件，下次续跑会检查同名 `.done` 标记文件并跳过。运行`python auto_download.sh`前记得把里面`scrape_mrgdatashare.py`运行的相关信息改一下


下载得到的图像通常还是原始 Bayer 格式，不是直接可视化的普通彩色图。
[process_dataset.py](process_dataset.py) 用来把 Bayer 原始图批量转换为普通的 RGB 彩色图；它内部会调用 [image.py](image.py) 的 `load_image` 进行去马赛克（`debayer=True`）。

使用前请先把脚本底部的路径改成你的实际目录，运行：`python process_dataset.py`



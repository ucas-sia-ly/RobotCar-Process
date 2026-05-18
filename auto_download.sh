#!/bin/bash

# 1. 安全退出机制
trap "echo -e '\n🛑 检测到手动中断 (Ctrl+C)，强制安全退出整个下载任务。'; rm -f current_run.txt; exit 1" INT

# 2. 前置检查
if [[ ! -f "scrape_mrgdatashare.py" || ! -f "my_runs.txt" ]]; then
    echo "❌ 错误: 找不到 scrape_mrgdatashare.py 或 my_runs.txt！"
    exit 1
fi

# 新增：提前创建输出文件夹和标记文件夹
mkdir -p ./outputs # -p：如果文件已存在，则不会报错，也不会覆盖
mkdir -p ./done_markers 

MAX_RETRIES=20 
DONE_DIR="./done_markers" # 独立存放标记的文件夹

# 逐行读取 my_runs.txt 中的序列
while IFS= read -r seq; do
    seq=$(echo "$seq" | tr -d '\r\n')
    [ -z "$seq" ] && continue
    
    echo "==== 🚀 开始处理序列: $seq ===="
    echo "$seq" > current_run.txt
    
    RETRY_COUNT=0
    
    while true; do
        # 🌟 传入 --done_dir 参数
        python scrape_mrgdatashare.py \
            --downloads_dir ./outputs/RobotCar \
            --datasets_file datasets.csv \
            --choice_runs_file current_run.txt \
            --choice_sensors stereo_centre,gps \
            --username  \
            --password  \
            --done_dir "$DONE_DIR"
                    
        EXIT_CODE=$?
        
        if [ $EXIT_CODE -eq 0 ]; then
            echo "🎉 序列 $seq 中的所有文件均已处理完毕！"
            break  
            
        elif [ $EXIT_CODE -eq 130 ]; then
            echo "🛑 检测到手动中断 (130退出码)，退出任务。"
            exit 130
            
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
                echo "❌ 序列 $seq 达到最大重试次数 ($MAX_RETRIES)，放弃并退出。"
                exit 1
            fi
            echo "⚠️ [重试 $RETRY_COUNT/$MAX_RETRIES] 遇到崩溃，5秒后 Python 将自动跳过已完成的文件并继续未完成的部分..."
            sleep 5
        fi
    done
done < my_runs.txt

rm -f current_run.txt
echo "🏁 所有序列已全部满载而归！"
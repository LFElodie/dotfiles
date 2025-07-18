#!/bin/bash
set -e

# 替换 apt 源为中科大镜像
sudo sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list
sudo sed -i 's/http:/https:/g' /etc/apt/sources.list

# 升级 pip 并配置 pypi 镜像源
pip install -i https://mirrors.ustc.edu.cn/pypi/web/simple pip -U
pip config set global.index-url https://mirrors.ustc.edu.cn/pypi/web/simple

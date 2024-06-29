FROM tianon/wine:8.0.2

#change source
RUN echo "# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释\n\
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free\n\
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free\n\
\n\
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free\n\
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free\n\
\n\
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free\n\
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free\n\
\n\
# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换\n\
deb https://security.debian.org/debian-security bullseye-security main contrib non-free\n\
# deb-src https://security.debian.org/debian-security bullseye-security main contrib non-free" > /etc/apt/sources.list

#deps
RUN apt-get update && apt-get install -y \
    git net-tools curl wget supervisor fluxbox xterm \
    x11vnc novnc xvfb xdotool \
    gnupg2 software-properties-common
RUN mkdir ~/.vnc && x11vnc -storepasswd vncpass ~/.vnc/passwd

#app user
RUN apt-get install -y sudo \
    && useradd -m app && usermod -aG sudo app && echo 'app ALL=(ALL) NOPASSWD:ALL' >> //etc/sudoers
#envs
RUN apt-get install -y ttf-wqy-microhei locales procps vim \
    && rm -rf /var/lib/apt/lists/* \
    && sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen
ENV DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=720 \
    DISPLAY=:0.0 \
    LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    WINEPREFIX=/home/app/.wine
#files
COPY root/ /
EXPOSE 8080
USER app
WORKDIR /home/app
# init with GUI
RUN bash -c 'nohup /entrypoint.sh 2>&1 &' && sleep 6 && /init.sh && sudo rm /tmp/.X0-lock
#settings
ENTRYPOINT ["/entrypoint.sh"]

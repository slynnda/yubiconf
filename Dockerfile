ARG docker_runtime_base_image="archlinux/base:latest"

FROM ${docker_runtime_base_image}

ARG docker_runtime_lang="en_US.UTF-8"
ARG docker_runtime_lc_all="en_US.UTF-8"
ARG docker_runtime_username="user"

ENV LANG ${docker_runtime_lang}
ENV LC_ALL ${docker_runtime_lc_all}

ENV YAY_REPO_URL https://aur.archlinux.org/yay.git
ENV YAY_TARGET_DIR /usr/local/src/aur.archlinux.org
ENV YAY_TARGET_NAME yay
ENV YAY_REPO_DIR ${YAY_TARGET_DIR}/${YAY_TARGET_NAME}

ENV RUNTIME_USER ${docker_runtime_username}
ENV RUNTIME_USER_SHELL /bin/sh
ENV RUNTIME_USER_GROUP wheel

RUN pacman --noconfirm -Syu git \
                            sudo \
                            make \
                            file \
                            gcc \
                            binutils \
                            fakeroot

RUN useradd --create-home \
            --gid ${RUNTIME_USER_GROUP} \
            --shell ${RUNTIME_USER_SHELL} ${RUNTIME_USER} && \
    echo "${RUNTIME_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir -p ${YAY_TARGET_DIR} && \
    git clone ${YAY_REPO_URL} ${YAY_REPO_DIR} && \
    chown -R ${RUNTIME_USER}:${RUNTIME_USER_GROUP} ${YAY_TARGET_DIR} && \
    cd ${YAY_REPO_DIR} && \
    sudo --user=${RUNTIME_USER} makepkg --noconfirm \
                                      --syncdeps \
                                      --install && \
    pacman --noconfirm -U *.tar.xz && \
    cd - && \
    test -f $(command -v ${YAY_TARGET_NAME}) && \
    echo "Successfully installed $(${YAY_TARGET_NAME} -v) to $(command -v ${YAY_TARGET_NAME})"

RUN sudo --user=${RUNTIME_USER} yay -Sy \
                                  --gitclone \
                                  --noconfirm coreutils \
                                              awk \
                                              unzip

RUN sudo --user=${RUNTIME_USER} yay -Sy \
                                  --gitclone \
                                  --noconfirm yubikey-manager && \
    test -f $(command -v ykman) && \
    $(command -v ykman) --version && \
    echo "Successfully installed yubikey-manager $(ykman --version) to $(command -v ykman)"

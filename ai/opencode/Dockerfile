FROM archlinux

RUN pacman -Sy --noconfirm --needed base-devel git curl ripgrep nodejs bun uv chromium

RUN mkdir -p /usr/local/bin/bun \
    && BUN_INSTALL=/usr/local/bin/bun bun i -g \
    opencode-ai@latest \
    oh-my-opencode-slim@latest \
    @tarquinen/opencode-dcp@latest \
    @th0rgal/ralph-wiggum@latest

ENV PATH="$PATH:/usr/local/bin/bun/bin"

ARG UNAME=opencode
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID $UNAME
RUN useradd -m -u $UID -g $GID $UNAME -G wheel \
    && passwd -d $UNAME \
    && echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers.d/temp


USER $UNAME

WORKDIR /home/$UNAME

RUN mkdir -p ~/.config/opencode ~/.local/share/opencode ~/.local/state/opencode

# RUN git clone https://aur.archlinux.org/paru.git \
#     && cd paru \
#     && makepkg -si --noconfirm

RUN sudo rm /etc/sudoers.d/temp

ENV OPENCODE_ENABLE_EXA=1

ENTRYPOINT ["opencode"]

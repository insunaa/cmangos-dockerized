FROM debian:trixie AS build
LABEL deleteme=false
RUN \
    mkdir /mangos && \
    apt update && \
    apt install -y \
    git \
    build-essential \
    g++ \
    gcc \
    automake \
    libsqlite3-dev \
    libtool \
    libssl-dev \
    binutils \
    libbz2-dev \
    cmake \
    libboost-all-dev \
    zlib1g-dev \
    ninja-build

FROM build AS build2
ARG PLAYERBOTS=1
ARG AHBOT=1
ARG CMANGOS_EXPANSION="wotlk"
LABEL deleteme=true
RUN git clone --single-branch --branch=master --depth=1 --recursive https://github.com/cmangos/mangos-${CMANGOS_EXPANSION}.git && \
    mkdir -p mangos-${CMANGOS_EXPANSION}/build && \
    cmake -Bmangos-${CMANGOS_EXPANSION}/build -Smangos-${CMANGOS_EXPANSION} -DPCH=1 -DDEBUG=0 -DUSE_ANTICHEAT=0 -DSQLITE=1 -DBUILD_EXTRACTORS=1 -DBUILD_AHBOT=${AHBOT} -DBUILD_PLAYERBOTS=${PLAYERBOTS} -DCMAKE_INSTALL_PREFIX=/mangos -DCMAKE_BUILD_TYPE=Release -GNinja -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_CXX_STANDARD=20 && \
    cd mangos-${CMANGOS_EXPANSION}/build && \
    ninja install && \
    mv -f /mangos/etc/mangosd.conf.dist /mangos/etc/mangosd.conf && \
    mv -f /mangos/etc/realmd.conf.dist /mangos/etc/realmd.conf && \
    mv -f /mangos/etc/ahbot.conf.dist /mangos/etc/ahbot.conf && \
    mv -f /mangos/etc/aiplayerbot.conf.dist /mangos/etc/aiplayerbot.conf && \
    mv -f /mangos/etc/anticheat.conf.dist /mangos/etc/anticheat.conf

FROM debian:trixie-slim
LABEL deleteme=false
ENV INSIDE_CONTAINER=true
COPY --from=build2 /mangos /mangos
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
    netcat-traditional \
    sqlite3 \
    wget \
    unzip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /mangos/bin

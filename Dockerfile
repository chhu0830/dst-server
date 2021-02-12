FROM cm2network/steamcmd:root

ENV SCRIPT_PATH="/usr/local/bin"
ENV INSTALL_PATH="/home/steam/Steam/steamapps/common/dst"
ENV CLUSTER_PATH="/home/steam/.klei/DoNotStarveTogether"

ENV CLUSTER_TOKE=${CLUSTER_TOKE:-""}
ENV CLUSTER_NAME=${CLUSTER_NAME:-"Cluster_1"}
ENV CLUSTER_PASS=${CLUSTER_PASS:-""}

RUN apt update
RUN apt install -y libcurl3-gnutls:i386

USER steam

WORKDIR "/home/steam/steamcmd"
RUN ./steamcmd.sh +login anonymous +force_install_dir $INSTALL_PATH +app_update 343050 validate +quit

RUN mkdir -p $CLUSTER_PATH
VOLUME ["$CLUSTER_PATH"]

# Generate Config Files
RUN echo "\
./steamcmd.sh +login anonymous +force_install_dir \$INSTALL_PATH +app_update 343050 validate +quit\n\
mkdir -p \$CLUSTER_PATH/\$CLUSTER_NAME/Master\n\
mkdir -p \$CLUSTER_PATH/\$CLUSTER_NAME/Caves\n\
\n\
cd \$CLUSTER_PATH/\$CLUSTER_NAME \n\
if [ ! -f cluster_token.txt ]; then\n\
    cat <<< \$CLUSTER_TOKE > cluster_token.txt\n\
fi\n\
\n\
if [ ! -f cluster.ini ]; then\n\
cat <<- EOF > cluster.ini\n\
    [GAMEPLAY]\n\
    game_mode = endless\n\
    max_players = 20\n\
    pvp = false\n\
    pause_when_empty = true\n\
    \n\
    [NETWORK]\n\
    cluster_description =\n\
    cluster_name = \$CLUSTER_NAME\n\
    cluster_intention = cooperative\n\
    cluster_password = \$CLUSTER_PASS\n\
    \n\
    [MISC]\n\
    console_enabled = true\n\
    \n\
    [SHARD]\n\
    shard_enabled = true\n\
    bind_ip = 127.0.0.1\n\
    master_ip = 127.0.0.1\n\
    master_port = 10889\n\
    cluster_key = supersecretkey\n\
EOF\n\
fi\n\
\n\
cd \$CLUSTER_PATH/\$CLUSTER_NAME/Master \n\
if [ ! -f server.ini ]; then\n\
cat <<- EOF > server.ini\n\
    [NETWORK]\n\
    server_port = 11000\n\
    \n\
    \n\
    [SHARD]\n\
    is_master = true\n\
    \n\
    \n\
    [STEAM]\n\
    master_server_port = 27018\n\
    authentication_port = 8768\n\
    \n\
    \n\
    [ACCOUNT]\n\
    encode_user_path = true\n\
EOF\n\
fi\n\
\n\
cd \$CLUSTER_PATH/\$CLUSTER_NAME/Caves \n\
if [ ! -f server.ini ]; then\n\
cat <<- EOF > server.ini\n\
    [NETWORK]\n\
    server_port = 11001\n\
    \n\
    \n\
    [SHARD]\n\
    is_master = false\n\
    name = Caves\n\
    \n\
    \n\
    [STEAM]\n\
    master_server_port = 27019\n\
    authentication_port = 8769\n\
    \n\
    \n\
    [ACCOUNT]\n\
    encode_user_path = true\n\
EOF\n\
fi\n\
\n\
if [ ! -f worldgenoverride.lua ]; then\n\
cat <<- EOF > worldgenoverride.lua\n\
    return {\n\
        override_enabled = true,\n\
        preset = \"DST_CAVE\",\n\
    }\n\
EOF\n\
fi\n\
\n\
cd $INSTALL_PATH/bin\n\
./dontstarve_dedicated_server_nullrenderer -console -cluster \$CLUSTER_NAME -shard Caves &\n\
./dontstarve_dedicated_server_nullrenderer -console -cluster \$CLUSTER_NAME -shard Master" > /tmp/entrypoint.sh

ENTRYPOINT ["bash", "/tmp/entrypoint.sh"]
CMD ["bash"]

ARG GODOT_VERSION="4.0.4"
ARG EXPORT_TEMPLATES="all"

FROM robpc/godot-headless:${GODOT_VERSION}-${EXPORT_TEMPLATES}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
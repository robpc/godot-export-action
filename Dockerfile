ENV GODOT_VERSION "3.2.3"
ENV EXPORT_TEMPLATE "all"

FROM robpc/godot-headless:${GODOT_VERSION}-${EXPORT_TEMPLATE}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
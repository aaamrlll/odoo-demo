FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Monterrey
ARG ODOO_DEB_URL

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    gnupg \
    postgresql-client \
    python3-pip \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN test -n "$ODOO_DEB_URL"

RUN wget -O /tmp/odoo.deb "$ODOO_DEB_URL" && \
    apt-get update && \
    apt-get install -y /tmp/odoo.deb && \
    rm -f /tmp/odoo.deb && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --break-system-packages phonenumbers

RUN mkdir -p /etc/odoo
COPY config/odoo.conf /etc/odoo/odoo.conf

RUN useradd -m -U -r -s /bin/bash odoo || true && \
    chown -R odoo:odoo /etc/odoo && \
    mkdir -p /var/lib/odoo && \
    chown -R odoo:odoo /var/lib/odoo

USER odoo

EXPOSE 8069 8072

CMD ["odoo", "-c", "/etc/odoo/odoo.conf"]
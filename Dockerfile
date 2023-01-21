FROM node:16
LABEL maintainer="Thomas Lemarchand"

# Try to keep the number of RUN statements low to avoid creating too many
# layers, and try to ensure that each layer would be useful to cache.

# Install Woob OS-level dependencies.
RUN apt-get update \
 && apt-get install -y locales git python3 python3-dev python3-pip python3-selenium libffi-dev \
    libxml2-dev libxslt-dev libyaml-dev libtiff-dev libjpeg-dev libopenjp2-7-dev zlib1g-dev \
    libfreetype6-dev libwebp-dev build-essential gcc g++ wget unzip mupdf-tools \
    libnss3-tools python3-nss \
 && rm -rf /var/lib/apt/lists/;

# Mundane tasks, all in one to reduce the number of layers:
# - Make sure the UTF-8 locale exists and is used by default.
# - Make sure python3 is used as default python version and link pip to pip3.
# - Then setup Kresus layout.
# - Tweak executable rights.
RUN locale-gen C.UTF-8 && \
    update-locale C.UTF-8 && \
    update-alternatives --install /usr/bin/python python $(which python3) 1 && \
    ln -s $(which pip3) /usr/bin/pip && \
    groupadd -g 900 -r kresus && useradd --no-log-init -u 900 -r -g kresus kresus && \
    mkdir -p /var/lib/kresus

# Install Rust for some Python dependencies.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Python dependencies.
RUN pip install --upgrade setuptools && \
    pip install simplejson BeautifulSoup4 PyExecJS typing-extensions pdfminer.six Pillow woob;

# Install Kresus.
RUN yarn global add kresus --prefix /opt/kresus --production;

# Run server.
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV HOST 0.0.0.0
ENV KRESUS_DIR /var/lib/kresus
#ENV KRESUS_WOOB_DIR /woob
ENV NODE_ENV production
ENV KRESUS_PYTHON_EXEC python3

USER kresus
VOLUME /var/lib/kresus
EXPOSE 9876

ENTRYPOINT ["/opt/kresus/bin/kresus"]

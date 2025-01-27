# Dockerfile for the MaxTract system https://github.com/zorkow/MaxTract/
#
# BUILD (from inside MaxTract):
# docker build .
#
# USAGE:
# docker run -v $PWD/samples:/samples <image-tag> ./extractElements.opt -h
# docker run -v $PWD/samples:/samples <image-tag> ./extractElements.opt -f /samples/pdf/test.pdf -d /samples/test

# docker run -v $PWD/samples:/samples <image-tag> linearizer.opt -h
# docker run -v $PWD/samples:/samples <image-tag> linearizer.opt /samples/test

# We use a build of ocaml that is json-wheel compatible
# Newer versions might also work
FROM ocaml/opam:ubuntu-16.04-ocaml-4.05

COPY --chown=opam:opam . /MaxTract

WORKDIR /MaxTract

USER root

# opam cannot find mikmatch_pcre so we install with apt
RUN \
  apt-get update && \
  apt-get install -y \
    libtiff-dev \
    libmikmatch-ocaml-dev \
    libocamlnet-ocaml-dev \
    pdftk \
    ghostscript \
    libtiff5

RUN \
  curl -L https://mjambon.github.io/mjambon2016/json-wheel.tar.gz -o json-wheel.tar.gz && \
  tar -xzf json-wheel.tar.gz && \
  make -C json-wheel && \
  make -C json-wheel install

USER opam

RUN \
  make -C src/ccl-tiff && \
  cp src/ccl-tiff/ccl src/pdfExtract/ && \
  make -C src/pdfExtract opt && \
  make -C src/linearize opt

WORKDIR src/pdfExtract
ENV PATH="$PATH:/MaxTract/src/linearize:/MaxTract/src/pdfExtract"
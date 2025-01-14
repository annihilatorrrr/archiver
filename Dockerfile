FROM golang:1.19.0-alpine as builder

RUN apk update && apk add --no-cache make ca-certificates tzdata && mkdir /build
COPY go.mod /build
RUN cd /build && go mod download
COPY . /build
RUN cd /build && make static


FROM alpine
RUN apk update && apk add --no-cache chromium-chromedriver
RUN wget -O /usr/share/fonts/TTF/SourceHanSans-VF.ttc \
    https://github.com/adobe-fonts/source-han-sans/raw/release/Variable/OTC/SourceHanSans-VF.ttf.ttc

ENV TZ=Asia/Shanghai
COPY --from=builder /build/archiver /archiver
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY entrypoint.sh /entrypoint.sh

WORKDIR /

CMD ["/bin/sh","/entrypoint.sh"]

# docker run -d --restart=always -e TOKEN="FXI" -e DRIVER=/usr/bin/chromedriver bennythink/archiver
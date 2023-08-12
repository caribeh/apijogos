FROM golang:1.18 AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /build

COPY . .

RUN go mod download
RUN go build -o app .

FROM alpine:latest

COPY --from=builder /build/app /app
COPY --from=builder /build/games.json /games.json

EXPOSE 8080

CMD ["/app"]
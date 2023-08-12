FROM golang:1.18 AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /build

COPY . .
COPY games.json .

RUN go mod download
RUN go build -o app .

FROM alpine:latest

COPY --from=builder /build/app /app

EXPOSE 8080

CMD ["/app"]
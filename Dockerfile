# Use a imagem base do Golang
FROM golang:1.16 AS builder

# Configurar variáveis de ambiente
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Definir o diretório de trabalho
WORKDIR /build

# Copiar o código fonte para o container
COPY . .

# Baixar as dependências e construir a aplicação
RUN go mod download
RUN go build -o app .

# Criar uma imagem menor baseada em Alpine
FROM alpine:latest

# Copiar o executável da aplicação construída
COPY --from=builder /build/app /app

# Expor a porta em que a aplicação vai rodar
EXPOSE 8080

# Executar a aplicação
CMD ["/app"]
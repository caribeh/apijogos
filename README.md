
# apijogos

Esta é uma simples API, sem persistência (por enquanto), onde teremos uma lista de jogos de diversas plataformas.


## Rodando localmente

Clone o projeto

```bash
  git clone https://github.com/caribeh/apijogos
```

Inicie o servidor

```bash
  go run main.go
```

## Rodando com Docker

```bash
  docker run -p 80:80 caribeh/apijogos:latest
```

## Documentação da API

#### Retorna todos os itens

```http
  GET /games
```

#### Retorna um item

```http
  GET /games/${id}
```

#### Adiciona um novo item

```http
  POST /games
```

#### Atualiza um item existente

```http
  PUT /games/${id}
```

#### Deleta um item existente

```http
  DELETE /games/${id}
```

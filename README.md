# API de Jogos

Bem-vindo à API de Jogos! Esta API permite que você gerencie uma lista de jogos, incluindo adição, consulta, atualização e exclusão de jogos. Utilizamos o pacote `github.com/gorilla/mux` para lidar com as rotas e solicitações HTTP.

## Base URL

A URL base para todos os endpoints da API é:

http://localhost:80

## Endpoints

### [GET] /healthcheck

Verifica o status de saúde da API.

#### Resposta de Exemplo

Status: 200 OK
"Healthy"

### [GET] /games

Retorna uma lista de todos os jogos disponíveis.

#### Resposta de Exemplo

Status: 200 OK
[
{
"ID": 1,
"Title": "Jogo A",
"Genre": "Aventura",
"Platform": "PC"
},
{
"ID": 2,
"Title": "Jogo B",
"Genre": "Estratégia",
"Platform": "PS5"
},
// ...
]

### [GET] /games/{id}

Retorna os detalhes de um jogo específico com base no ID.

#### Parâmetros

- `id` (int): O ID do jogo a ser consultado.

#### Resposta de Exemplo

Status: 200 OK
{
"ID": 1,
"Title": "Jogo A",
"Genre": "Aventura",
"Platform": "PC"
}

### [POST] /games

Adiciona um novo jogo à lista de jogos.

#### Corpo da Solicitação

{
"Title": "Novo Jogo",
"Genre": "Ação",
"Platform": "Xbox Series X"
}

#### Resposta de Exemplo

Status: 201 Created
{
"ID": 3,
"Title": "Novo Jogo",
"Genre": "Ação",
"Platform": "Xbox Series X"
}

### [PUT] /games/{id}

Atualiza os detalhes de um jogo existente com base no ID.

#### Parâmetros

- `id` (int): O ID do jogo a ser atualizado.

#### Corpo da Solicitação

{
"Title": "Jogo Atualizado",
"Genre": "Aventura",
"Platform": "Nintendo Switch"
}

#### Resposta de Exemplo

Status: 200 OK
{
"ID": 1,
"Title": "Jogo Atualizado",
"Genre": "Aventura",
"Platform": "Nintendo Switch"
}

### [DELETE] /games/{id}

Remove um jogo da lista com base no ID.

#### Parâmetros

- `id` (int): O ID do jogo a ser removido.

#### Resposta de Exemplo

Status: 204 No Content

## Erros Possíveis

### Resposta de Erro Padrão

Status: 400 Bad Request
{
"error": "Descrição do erro"
}

### Jogo não Encontrado

Status: 404 Not Found

### Jogo com Mesmo Nome Já Existe

Status: 400 Bad Request
{
"error": "Game with the same name already exists"
}

## Como Executar

1. Certifique-se de ter o Go instalado em seu sistema.
2. Clone este repositório.
3. Instale as dependências com `go mod tidy`.
4. Execute o servidor com `go run main.go`.

---

**Lembre-se de ajustar as URLs e exemplos de acordo com o seu ambiente de desenvolvimento.**

Desenvolvido por [Bruno Caribé](https://github.com/caribeh).
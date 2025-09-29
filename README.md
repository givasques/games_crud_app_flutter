# 🎮 VideoGame App

VideoGame App é um aplicativo Flutter para listar, adicionar e editar jogos. Ele consome uma API REST para gerenciar os dados dos jogos e exibe prévias de imagens em tempo real.

## 🚀 Tecnologias Utilizadas

Frontend: Flutter

Backend: API REST (qualquer servidor que você esteja usando)

HTTP Requests: pacote http

State Management: setState simples (pode ser evoluído para Provider, Riverpod etc.)

## 📌 Funcionalidades

Listar todos os jogos disponíveis

Adicionar novos jogos (nome, plataforma, URL da imagem)

Editar jogos existentes

Pré-visualização da imagem ao digitar a URL

Validação de campos obrigatórios

Suporte a feedback visual em caso de erro de carregamento de imagem

## 🛠️ Estrutura da API

Endpoints utilizados:

Método	Endpoint	Descrição
GET	/games	Lista todos os jogos
GET	/games/{id}	Buscar jogo por ID
POST	/games	Criar novo jogo
PUT	/games/{id}	Atualizar jogo existente
DELETE	/games/{id}	Deletar jogo
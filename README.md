# Intelbras Automation

Este projeto é um projeto em Robot Framework para o projeto da Intelbras que terá testes de API e testes E2E. O teste de API será realizado utilizando o Swagger disponível em [Swagger API Documentation](http://18.228.160.85:5000/docs#/).

## Requisitos

- Python 3.x
- Robot Framework
- Requests Library

## Instalação

1. Clone o repositório:
    ```sh
    git clone https://github.com/edgebr/intelbras-automation.git
    ```

2. Navegue até o diretório do projeto:
    ```sh
    cd intelbras-automation
    ```

3. Instale as dependências:
    ```sh
    pip install -r requirements.txt
    ```

## Estrutura do Projeto

- `resources/`: Contém os recursos e bibliotecas utilizadas nos testes.
- `tests/`: Contém os casos de teste organizados por funcionalidade.

## Executando os Testes

Para executar os testes, utilize o comando:
```sh
robot -d results tests/
```

## Repositório

- [GitHub Repository](https://github.com/edgebr/intelbras-automation)


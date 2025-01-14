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

3. Crie e ative um ambiente virtual:
    ```sh
    python -m venv venv
    source venv/bin/activate  # No Windows use `venv\Scripts\activate`
    ```

4. Instale as dependências:
    ```sh
    pip install -r requirements.txt
    ```

## Estrutura do Projeto

- [resources](http://_vscodecontentref_/1): Contém os recursos e bibliotecas utilizadas nos testes.
  - `page/api/`: Contém os recursos organizados por funcionalidade de API.
  - `e2e/`: Contém os recursos para testes end-to-end.
- [test](http://_vscodecontentref_/2): Contém os casos de teste organizados por funcionalidade.
  - `api/`: Contém os testes de API organizados por funcionalidade.
  - `e2e/`: Contém os testes end-to-end organizados por funcionalidade.
- [venv](http://_vscodecontentref_/3): Ambiente virtual para dependências do Python.

## Executando os Testes

Para executar os testes, utilize o comando:
```sh
robot -d results test/
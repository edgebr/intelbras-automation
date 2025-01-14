### 1. **Testes para Métodos GET**
#### **Status Codes Esperados**
- **200 OK**: Quando a requisição é bem-sucedida e o recurso é retornado.
- **404 Not Found**: Quando o recurso solicitado não existe.
- **401 Unauthorized**: Quando é necessária autenticação, mas não fornecida ou incorreta.
- **403 Forbidden**: Quando a autenticação é válida, mas o acesso ao recurso é restrito.

#### **O que validar?**
- **Schema de resposta**: Use uma ferramenta como JSON Schema para verificar se a resposta segue o contrato esperado.
- **Headers de resposta**: Exemplo: `Content-Type: application/json`.
- **Tempo de resposta**: Deve estar dentro do SLA definido.
- **Paginação**: Verificar se as respostas suportam e retornam dados paginados corretamente.
- **Filtros e parâmetros**: Valide combinações de parâmetros, incluindo valores inválidos ou não suportados.
- **Cache**: Caso aplicável, verifique se a resposta possui cabeçalhos como `Cache-Control` ou `ETag`.

---

### 2. **Testes para Métodos POST**
#### **Status Codes Esperados**
- **201 Created**: Quando o recurso é criado com sucesso.
- **400 Bad Request**: Quando os dados enviados no corpo da requisição estão incorretos.
- **401 Unauthorized** ou **403 Forbidden**: Quando a autenticação está ausente ou inválida.
- **409 Conflict**: Para casos de duplicidade (e.g., criando um recurso com ID já existente).
- **500 Internal Server Error**: Quando há erro no servidor.

#### **O que validar?**
- **Validação do corpo da requisição**: Enviar dados válidos e inválidos para validar comportamentos.
- **Mensagens de erro**: Certifique-se de que mensagens sejam claras e sigam um padrão.
- **Headers da requisição**: Incluindo `Content-Type` e `Authorization`.
- **Resposta da criação**: O ID ou URI do novo recurso deve ser retornado.
- **Carga limite**: Testar limites de payload e possíveis problemas com grandes volumes de dados.

---

### 3. **Testes para Métodos PUT**
#### **Status Codes Esperados**
- **200 OK** ou **204 No Content**: Quando a atualização é bem-sucedida.
- **400 Bad Request**: Dados inválidos enviados.
- **404 Not Found**: O recurso a ser atualizado não existe.
- **401 Unauthorized** ou **403 Forbidden**: Falhas de autenticação ou autorização.
- **409 Conflict**: Conflitos de dados, como versões desatualizadas do recurso.

#### **O que validar?**
- **Validação do corpo da requisição**: Dados completos e parciais (se suportado).
- **Idempotência**: Garantir que múltiplas requisições PUT com os mesmos dados não criem novos recursos.
- **Validação de respostas**: Confirmação de que os dados foram atualizados corretamente.

---

### 4. **Testes para Métodos DELETE**
#### **Status Codes Esperados**
- **204 No Content**: Quando o recurso é deletado com sucesso.
- **404 Not Found**: O recurso não existe.
- **401 Unauthorized** ou **403 Forbidden**: Falha de autenticação ou autorização.

#### **O que validar?**
- **Confirmação da exclusão**: Tentar acessar o recurso novamente e verificar o retorno de **404 Not Found**.
- **Idempotência**: Verificar que a mesma requisição DELETE múltiplas vezes retorna o mesmo resultado.
- **Dependências**: Garantir que recursos relacionados são tratados corretamente ou sinalizar dependências.

---

### 5. **Melhorias sugeridas**
Se a documentação da API não fornece status codes esperados ou mensagens detalhadas:
- **Adicionar tabelas de status codes**: Associando cada endpoint aos seus códigos de resposta possíveis.
- **Mensagens de erro padronizadas**: Como `{ "error": "Invalid data", "details": "Field X is required" }`.
- **Definir contratos de entrada/saída com JSON Schema**.

---

### 6. **Outras áreas de teste**
- **Testes de segurança**:
  - Verificar injeções (SQL, XSS).
  - Testar limites de autenticação (e.g., brute force).
  - Garantir que dados sensíveis não são retornados em logs ou respostas.
- **Testes de desempenho**:
  - Simular múltiplas requisições concorrentes.
  - Validar latência e throughput.
- **Testes exploratórios**:
  - Testar combinações inesperadas de métodos e parâmetros.

---

### Tabela de Status Codes Sugeridos por Método HTTP

| **Método** | **Status Code** | **Descrição**                          | **Quando Usar**                                     |
|------------|----------------|--------------------------------------|---------------------------------------------------|
| **GET**    | 200 OK         | Requisição bem-sucedida.            | Quando os dados são recuperados com sucesso.     |
|            | 401 Unauthorized| Não autorizado.                     | Quando a autenticação não é fornecida ou é inválida. |
|            | 403 Forbidden   | Acesso proibido.                    | Quando o acesso é restrito mesmo com autenticação.|
|            | 404 Not Found   | Recurso não encontrado.             | Quando o recurso solicitado não existe.          |
|            | 500 Internal Server Error | Erro interno no servidor.    | Quando ocorre um erro inesperado no servidor.     |
| **POST**   | 201 Created    | Recurso criado com sucesso.         | Quando um novo recurso é criado.                 |
|            | 400 Bad Request| Dados inválidos na requisição.      | Quando o payload está incorreto ou incompleto.    |
|            | 401 Unauthorized| Não autorizado.                     | Sem autenticação ou autenticação inválida.        |
|            | 403 Forbidden   | Proibido.                           | Acesso negado mesmo com autenticação.            |
|            | 409 Conflict    | Conflito.                           | Quando um recurso já existe e não pode ser duplicado. |
|            | 500 Internal Server Error | Erro interno no servidor.    | Quando há falhas internas durante a criação do recurso. |
| **PUT**    | 200 OK         | Atualização bem-sucedida.           | Quando os dados de um recurso são atualizados.   |
|            | 204 No Content  | Atualização sem retorno de conteúdo.| Quando a atualização não retorna dados no corpo. |
|            | 400 Bad Request| Dados inválidos na requisição.      | Payload com erros de validação.                  |
|            | 404 Not Found   | Recurso não encontrado.             | Quando o recurso a ser atualizado não existe.    |
|            | 409 Conflict    | Conflito.                           | Erros de concorrência ou inconsistência de versão.|
| **DELETE** | 204 No Content  | Recurso deletado com sucesso.       | Quando o recurso é excluído.                     |
|            | 404 Not Found   | Recurso não encontrado.             | Quando o recurso já foi removido ou não existe.  |
|            | 401 Unauthorized| Não autorizado.                     | Quando a autenticação é inválida ou ausente.     |
|            | 403 Forbidden   | Acesso proibido.                    | Quando o usuário não tem permissão para excluir. |
|            | 500 Internal Server Error | Erro interno no servidor.    | Falhas inesperadas ao excluir o recurso.         |

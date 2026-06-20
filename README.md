# Resultados finais da execução

Os resultados finais estão salvos no próprio repositório.

## Arquivos de saída do programa

- [LOG_PROCESSAMENTO.TXT](out_from_container/LOG_PROCESSAMENTO.TXT)
- [SAIDA.TXT](out_from_container/SAIDA.TXT)
- [ERROS.TXT](out_from_container/ERROS.TXT)
- [RELATORIO_PROCESSAMENTO.TXT](out_from_container/RELATORIO_PROCESSAMENTO.TXT)
- [RELATORIO_DETALHADO.TXT](out_from_container/RELATORIO_DETALHADO.TXT)

## Estado final do banco Db2

- [00_CONNECT.TXT](db_state_from_container/00_CONNECT.TXT)
- [01_CLIENTES.TXT](db_state_from_container/01_CLIENTES.TXT)
- [02_TRANSACOES.TXT](db_state_from_container/02_TRANSACOES.TXT)
- [03_ERROS_PROCESSAMENTO.TXT](db_state_from_container/03_ERROS_PROCESSAMENTO.TXT)
- [04_COUNT_CLIENTES.TXT](db_state_from_container/04_COUNT_CLIENTES.TXT)
- [05_COUNT_TRANSACOES.TXT](db_state_from_container/05_COUNT_TRANSACOES.TXT)
- [06_COUNT_ERROS.TXT](db_state_from_container/06_COUNT_ERROS.TXT)

# Objetivo do projeto

Este projeto implementa um processamento bancário em COBOL usando Db2.

O programa:

- lê arquivos fixos ordenados de clientes e transações;
- insere clientes na tabela `CLIENTES`;
- processa transações de crédito e débito;
- atualiza o saldo dos clientes no Db2;
- registra transações válidas na tabela `TRANSACOES`;
- valida regras de negócio;
- grava erros em arquivo e na tabela `ERROS_PROCESSAMENTO`;
- executa `COMMIT`;
- executa `ROLLBACK` em erro grave de SQL;
- gera arquivos de saída, relatório e log.

---

# Estrutura do projeto

```text
projeto_cobol/
├── copy/
│   └── db2/
│       └── sqlca.cbl
├── data/
│   ├── CLIENTES.TXT
│   ├── TRANSACOES.TXT
│   ├── CLIENTES.ORD
│   └── TRANSACOES.ORD
├── out_from_container/
│   ├── ERROS.TXT
│   ├── LOG_PROCESSAMENTO.TXT
│   ├── RELATORIO_DETALHADO.TXT
│   ├── RELATORIO_PROCESSAMENTO.TXT
│   └── SAIDA.TXT
├── db_state_from_container/
│   ├── 00_CONNECT.TXT
│   ├── 01_CLIENTES.TXT
│   ├── 02_TRANSACOES.TXT
│   ├── 03_ERROS_PROCESSAMENTO.TXT
│   ├── 04_COUNT_CLIENTES.TXT
│   ├── 05_COUNT_TRANSACOES.TXT
│   └── 06_COUNT_ERROS.TXT
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_clear_tables.sql
│   └── 03_check_results.sql
└── src/
    ├── PROG06.cob
    ├── PROG06_precompiled_ansi.cbl
    ├── PROG06_ansi.bnd
    └── PROG06_precompile_ansi.msg
```

---

# Pré-requisitos

Para executar o projeto, é necessário ter:

- Linux;
- Podman;
- container IBM Db2 rodando com o nome `db2server`;
- banco Db2 chamado `BANCO`;
- usuário Db2 `db2inst1`;
- GnuCOBOL instalado dentro do container Db2.

O ambiente usado foi:

```text
IBM Db2 11.5.9
Container: db2server
Banco: BANCO
Usuário: db2inst1
```

---

# Observação importante

O executável COBOL deve ser compilado dentro do container Db2.

Durante o desenvolvimento, compilar no host e executar dentro do container gerou erro de versão da `glibc`, como:

```text
/lib64/libc.so.6: version `GLIBC_2.34' not found
```

A solução foi compilar dentro do próprio container, usando as bibliotecas do Db2 instaladas em:

```text
/opt/ibm/db2/V11.5/lib64
```

---

# Como executar o projeto

## 1. Ordenar os arquivos de entrada

Execute no host, dentro da raiz do projeto:

```bash
sort -k1.1,1.5 data/CLIENTES.TXT > data/CLIENTES.ORD
sort -k1.1,1.5 -k1.6,1.10 data/TRANSACOES.TXT > data/TRANSACOES.ORD
```

Verifique se não há `TRX_ID` duplicado:

```bash
cut -c6-10 data/TRANSACOES.ORD | sort | uniq -d
```

Se o comando não imprimir nada, os códigos das transações estão sem duplicidade.

---

## 2. Criar ou limpar as tabelas no Db2

Copie os scripts SQL para o container:

```bash
podman cp sql/01_create_tables.sql db2server:/tmp/01_create_tables.sql
podman cp sql/02_clear_tables.sql db2server:/tmp/02_clear_tables.sql
```

Se for a primeira execução, crie as tabelas:

```bash
podman exec -it db2server bash -lc '
su - db2inst1 -c "
db2 connect to BANCO
db2 -tvf /tmp/01_create_tables.sql
"
'
```

Para repetir a execução com o banco limpo:

```bash
podman exec -it db2server bash -lc '
su - db2inst1 -c "
db2 connect to BANCO
db2 -tvf /tmp/02_clear_tables.sql
"
'
```

---

## 3. Copiar os arquivos de entrada para o container

```bash
podman exec -u root -it db2server bash -lc '
mkdir -p /tmp/data /tmp/out /tmp/db_state
rm -f /tmp/out/*.TXT
chown -R db2inst1:db2iadm1 /tmp/data /tmp/out /tmp/db_state
'

podman cp data/CLIENTES.ORD db2server:/tmp/data/CLIENTES.ORD
podman cp data/TRANSACOES.ORD db2server:/tmp/data/TRANSACOES.ORD

podman exec -u root -it db2server bash -lc '
chown -R db2inst1:db2iadm1 /tmp/data /tmp/out /tmp/db_state
chmod -R u+rwX /tmp/data /tmp/out /tmp/db_state
'
```

---

## 4. Copiar o COBOL pré-compilado e o copybook SQLCA

```bash
podman cp src/PROG06_precompiled_ansi.cbl db2server:/tmp/PROG06_precompiled_ansi.cbl
podman cp copy/db2/sqlca.cbl db2server:/tmp/sqlca.cbl
```

---

## 5. Compilar dentro do container

```bash
podman exec -u root -it db2server bash -lc '
cd /tmp

export LD_LIBRARY_PATH=/opt/ibm/db2/V11.5/lib64:$LD_LIBRARY_PATH

cobc -x -fixed -Wall -std=mf -fstatic-call \
  -I /tmp \
  -I /database/config/db2inst1/sqllib/include/cobol_mf \
  -o prog06_el8 \
  PROG06_precompiled_ansi.cbl \
  -L/opt/ibm/db2/V11.5/lib64 -ldb2

chmod 755 prog06_el8
chown db2inst1:db2iadm1 prog06_el8
'
```

Durante a compilação, podem aparecer avisos como:

```text
LABEL RECORDS is obsolete
RECORD clause ignored for LINE SEQUENTIAL
DATA RECORDS is obsolete
```

Esses avisos são esperados porque o código mantém estilo parecido com COBOL antigo/TK5, mas usa arquivos locais `LINE SEQUENTIAL`.

---

## 6. Executar o programa

```bash
podman exec -it db2server bash -lc '
su - db2inst1 -c "
cd /tmp
. /database/config/db2inst1/sqllib/db2profile
export LD_LIBRARY_PATH=/opt/ibm/db2/V11.5/lib64:\$LD_LIBRARY_PATH
./prog06_el8
"
'
```

---

## 7. Copiar os arquivos de saída para o host

```bash
rm -rf out_from_container
podman cp db2server:/tmp/out ./out_from_container
```

Arquivos esperados:

```text
out_from_container/
├── ERROS.TXT
├── LOG_PROCESSAMENTO.TXT
├── RELATORIO_DETALHADO.TXT
├── RELATORIO_PROCESSAMENTO.TXT
└── SAIDA.TXT
```

---

## 8. Exportar o estado final do banco Db2

```bash
podman exec -i db2server bash <<'EOF'
su - db2inst1 -c '
mkdir -p /tmp/db_state

db2 connect to BANCO > /tmp/db_state/00_CONNECT.TXT

db2 "select * from CLIENTES order by CLI_ID" \
  > /tmp/db_state/01_CLIENTES.TXT

db2 "select * from TRANSACOES order by TRX_ID" \
  > /tmp/db_state/02_TRANSACOES.TXT

db2 "select * from ERROS_PROCESSAMENTO order by ID_ERRO" \
  > /tmp/db_state/03_ERROS_PROCESSAMENTO.TXT

db2 "select count(*) as QTD_CLIENTES from CLIENTES" \
  > /tmp/db_state/04_COUNT_CLIENTES.TXT

db2 "select count(*) as QTD_TRANSACOES from TRANSACOES" \
  > /tmp/db_state/05_COUNT_TRANSACOES.TXT

db2 "select count(*) as QTD_ERROS from ERROS_PROCESSAMENTO" \
  > /tmp/db_state/06_COUNT_ERROS.TXT
'
EOF

rm -rf db_state_from_container
podman cp db2server:/tmp/db_state ./db_state_from_container
```

---

# Layout dos arquivos de entrada

## `CLIENTES.TXT` / `CLIENTES.ORD`

```text
CLI-ID      5 posições
CLI-NOME    30 posições
CLI-SALDO   9 posições
```

Total:

```text
44 caracteres
```

Exemplo:

```text
00123JOAO SILVA                    000010000
```

---

## `TRANSACOES.TXT` / `TRANSACOES.ORD`

```text
TRX-CLI-ID   5 posições
TRX-ID       5 posições
TRX-TIPO     1 posição
TRX-VALOR    9 posições
```

Total:

```text
20 caracteres
```

Exemplo:

```text
0012300001C000000500
```

Tipos de transação:

```text
C = crédito
D = débito
```

---

# Tabelas Db2

## `CLIENTES`

```sql
CREATE TABLE CLIENTES (
  CLI_ID INTEGER NOT NULL,
  CLI_NOME VARCHAR(30) NOT NULL,
  CLI_SALDO DECIMAL(9,0) NOT NULL,
  DT_ATUALIZACAO DATE,
  PRIMARY KEY (CLI_ID)
);
```

## `TRANSACOES`

```sql
CREATE TABLE TRANSACOES (
  TRX_ID INTEGER NOT NULL,
  CLI_ID INTEGER NOT NULL,
  TRX_TIPO CHAR(1) NOT NULL,
  TRX_VALOR DECIMAL(9,0) NOT NULL,
  DT_PROCESSAMENTO DATE,
  PRIMARY KEY (TRX_ID)
);
```

## `ERROS_PROCESSAMENTO`

```sql
CREATE TABLE ERROS_PROCESSAMENTO (
  ID_ERRO INTEGER GENERATED ALWAYS AS IDENTITY,
  CLI_ID INTEGER,
  DESCRICAO_ERRO VARCHAR(100),
  DT_OCORRENCIA TIMESTAMP
);
```

---

# Regras de negócio implementadas

O programa valida:

- cliente inexistente;
- tipo de transação inválido;
- valor de transação zerado;
- saldo insuficiente para débito;
- crédito válido;
- débito válido;
- atualização de saldo;
- gravação em tabela de erros;
- gravação em arquivo de erros;
- gravação de log de processamento.

---

# Problemas encontrados e soluções

## 1. Driver Db2 do host não era suficiente

O driver Db2 instalado no host conseguia validar conexão, mas não exportava símbolos necessários para embedded SQL, como:

```text
sqlgstrt
sqlgaloc
sqlgstlv
sqlgcall
sqlgstop
```

Solução:

```text
Usar as bibliotecas completas do Db2 dentro do container.
```

---

## 2. Binário compilado no host não rodava no container

Erro encontrado:

```text
/lib64/libc.so.6: version `GLIBC_2.34' not found
```

Solução:

```text
Compilar o programa dentro do container Db2.
```

---

## 3. Caminho correto da biblioteca Db2

O container usado possui Db2 11.5.9 instalado em:

```text
/opt/ibm/db2/V11.5
```

Por isso o caminho correto de linkedição foi:

```text
/opt/ibm/db2/V11.5/lib64
```

---

## 4. Permissão nos arquivos de saída

O programa roda como `db2inst1`, então as pastas `/tmp/data`, `/tmp/out` e `/tmp/db_state` precisam pertencer a esse usuário:

```bash
chown -R db2inst1:db2iadm1 /tmp/data /tmp/out /tmp/db_state
```

---

## 5. `TRX_ID` duplicado

A tabela `TRANSACOES` usa `TRX_ID` como chave primária.

Quando havia transações com o mesmo `TRX_ID`, o Db2 retornava:

```text
SQLCODE=-000803
```

Solução:

```text
Corrigir os códigos duplicados no arquivo TRANSACOES.TXT.
```

---

# Conclusão

O projeto foi executado com sucesso usando:

```text
COBOL + GnuCOBOL + Db2 11.5 + Podman
```

O programa conectou ao Db2, processou clientes e transações, gravou saídas em arquivos, registrou erros esperados e exportou o estado final das tabelas para conferência.

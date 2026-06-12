# Projeto 5 — Processamento de Transações Bancárias em COBOL

## Descrição

Este projeto implementa um sistema de processamento de transações bancárias utilizando **COBOL** e **JCL** no ambiente **TK5/MVS 3.8J**.

O programa recebe dois arquivos:

* um arquivo contendo os clientes e seus respectivos saldos;
* um arquivo contendo transações de crédito e débito.

Os dois arquivos são ordenados por ID e processados em conjunto por meio de uma lógica de **MATCH/MERGE**.

Ao final, o sistema:

* atualiza os saldos dos clientes;
* gera um novo arquivo com os clientes atualizados;
* registra transações inválidas em um arquivo de erros;
* apresenta totais de crédito e débito por cliente;
* exibe as estatísticas gerais do processamento.

---

### Arquivos principais

* `PROG05.cob`: programa COBOL responsável pelo processamento.
* `COMPILE5.JCL`: job utilizado para compilar e gerar o módulo executável.
* `EXEC5.JCL`: job responsável por ordenar os arquivos e executar o programa.
* `CLIENTES.TXT`: arquivo de entrada com os clientes.
* `TRANSACOES.TXT`: arquivo de entrada com as transações.
* `ATUAL.TXT`: arquivo de saída com os saldos atualizados.
* `ERROS.TXT`: arquivo contendo as inconsistências encontradas.

---

## Arquivo de clientes

O arquivo `CLIENTES.TXT` possui registros de tamanho fixo com 44 caracteres.

### Layout

```cobol
01 REG-CLIENTE.
   05 CLI-ID       PIC 9(05).
   05 CLI-NOME     PIC X(30).
   05 CLI-SALDO    PIC 9(09).
```

### Estrutura

| Campo       | Tamanho | Descrição                |
| ----------- | ------: | ------------------------ |
| `CLI-ID`    |       5 | Identificador do cliente |
| `CLI-NOME`  |      30 | Nome do cliente          |
| `CLI-SALDO` |       9 | Saldo atual do cliente   |

### Exemplo

```text
00123JOAO SILVA                    000010000
00456MARIA SOUZA                  000025000
00789CARLOS PEREIRA               000005000
```

### Atributos do dataset

```text
RECFM=FB
LRECL=44
BLKSIZE=440
```

---

## Arquivo de transações

O arquivo `TRANSACOES.TXT` possui registros de tamanho fixo com 20 caracteres.

### Layout

```cobol
01 REG-TRANSACAO.
   05 TRX-CLI-ID   PIC 9(05).
   05 TRX-ID       PIC 9(05).
   05 TRX-TIPO     PIC X(01).
   05 TRX-VALOR    PIC 9(09).
```

### Estrutura

| Campo        | Tamanho | Descrição                           |
| ------------ | ------: | ----------------------------------- |
| `TRX-CLI-ID` |       5 | Identificador do cliente            |
| `TRX-ID`     |       5 | Identificador da transação          |
| `TRX-TIPO`   |       1 | `C` para crédito ou `D` para débito |
| `TRX-VALOR`  |       9 | Valor da transação                  |

### Exemplo

```text
0012300010C000000500
0012300020D000000200
0045600030D000001000
```

### Atributos do dataset

```text
RECFM=FB
LRECL=20
BLKSIZE=200
```

---

## Funcionamento do programa

O processamento é dividido nas seguintes etapas:

1. Ordenação do arquivo de clientes por ID.
2. Ordenação do arquivo de transações por ID do cliente e ID da transação.
3. Leitura do primeiro registro de cada arquivo.
4. Comparação entre o ID do cliente e o ID presente na transação.
5. Processamento das transações correspondentes.
6. Gravação do cliente com o saldo atualizado.
7. Registro das transações inválidas.
8. Exibição das estatísticas finais.

---

## Lógica MATCH/MERGE

O programa mantém um cliente e uma transação em memória e compara seus identificadores.

### IDs iguais

Quando o ID do cliente é igual ao ID da transação:

```text
CLI-ID = TRX-CLI-ID
```

A transação pertence ao cliente atual.

O programa:

* valida a transação;
* aplica o crédito ou débito;
* atualiza os totais do cliente;
* lê a próxima transação.

O cliente permanece em memória porque pode possuir outras transações.

### ID do cliente menor

Quando:

```text
CLI-ID < TRX-CLI-ID
```

não existem mais transações para o cliente atual.

O programa:

* grava o cliente no arquivo atualizado;
* exibe os totais de crédito e débito;
* lê o próximo cliente.

### ID da transação menor

Quando:

```text
CLI-ID > TRX-CLI-ID
```

a transação pertence a um cliente inexistente.

O programa:

* registra o erro;
* ignora a transação;
* lê a próxima transação.

---

## Atualização dos saldos

### Crédito

Uma transação do tipo `C` adiciona o valor ao saldo:

```cobol
ADD TRX-VALOR TO CLI-SALDO.
```

### Débito

Uma transação do tipo `D` subtrai o valor do saldo:

```cobol
SUBTRACT TRX-VALOR FROM CLI-SALDO.
```

O débito somente é aplicado quando o cliente possui saldo suficiente.

---

## Tratamento de erros

O programa valida todas as transações recebidas.

### Cliente inexistente

Ocorre quando uma transação possui um ID que não existe no arquivo de clientes.

```text
ERRO: CLIENTE NAO ENCONTRADO - ID 99999
```

### Tipo de transação inválido

O campo de tipo deve conter somente:

```text
C = crédito
D = débito
```

Qualquer outro valor gera:

```text
ERRO: TIPO DE TRANSACAO INVALIDO - ID 00123
```

### Valor de transação zerado

Transações com valor igual a zero são rejeitadas:

```text
ERRO: VALOR DE TRANSACAO INVALIDO - ID 00123
```

### Saldo insuficiente

Quando um débito deixaria o saldo abaixo de zero:

```text
ERRO: SALDO INSUFICIENTE - ID 00123
```

A transação não é aplicada ao saldo do cliente.

---

## Arquivo de clientes atualizados

O arquivo `ATUAL.TXT` possui o mesmo layout do arquivo de clientes.

```cobol
01 REG-CLIENTE-ATU.
   05 ATU-CLI-ID       PIC 9(05).
   05 ATU-CLI-NOME     PIC X(30).
   05 ATU-CLI-SALDO    PIC 9(09).
```

Exemplo:

```text
00123JOAO SILVA                    000010300
00456MARIA SOUZA                  000024000
00789CARLOS PEREIRA               000005000
```

Clientes sem transações também são gravados no arquivo, mantendo o saldo original.

---

## Relatório por cliente

Para cada cliente processado, o programa apresenta:

```text
CLIENTE: 00123
TOTAL CREDITOS: 000000500
TOTAL DEBITOS: 000000200
```

Clientes sem transações apresentam os totais zerados:

```text
CLIENTE: 00789
TOTAL CREDITOS: 000000000
TOTAL DEBITOS: 000000000
```

---

## Estatísticas de processamento

Ao final da execução, o programa exibe:

```text
****************************************
ESTATISTICAS DE PROCESSAMENTO
****************************************
CLIENTES PROCESSADOS.....: 000003
TRANSACOES PROCESSADAS...: 000010
CREDITOS PROCESSADOS.....: 000006
DEBITOS PROCESSADOS......: 000004
ERROS ENCONTRADOS........: 000002
FIM DO PROCESSAMENTO
```

### Significado dos contadores

* `CLIENTES PROCESSADOS`: clientes gravados no arquivo atualizado.
* `TRANSACOES PROCESSADAS`: transações lidas e analisadas.
* `CREDITOS PROCESSADOS`: créditos válidos aplicados.
* `DEBITOS PROCESSADOS`: débitos válidos aplicados.
* `ERROS ENCONTRADOS`: transações rejeitadas e registradas no arquivo de erros.

---

## Organização do código COBOL

O programa foi dividido em procedimentos responsáveis por tarefas específicas:

```text
MAIN-PROCEDURE
ABRIR-ARQUIVOS
LER-CLIENTE
LER-TRANSACAO
FLUXO-MERGE
PROCESSAR-TRANSACAO
PROCESSAR-CREDITO
PROCESSAR-DEBITO
FINALIZAR-CLIENTE
TRANSACAO-SEM-CLIENTE
GRAVAR-ERRO
GERAR-RELATORIO-CLIENTE
EXIBIR-ESTATISTICAS
FECHAR-ARQUIVOS
```

Essa organização facilita a leitura, manutenção e identificação de cada etapa do processamento.

Os nomes dos procedimentos também podem utilizar numeração, como:

```text
0000-PRINCIPAL
1000-INICIALIZAR
2000-PROCESSAR
3000-FINALIZAR-CLIENTE
9000-FINALIZAR
```

A numeração é uma convenção de organização utilizada em muitos programas COBOL, mas não altera a ordem de execução. Os procedimentos são executados pelos comandos `PERFORM`.

---

## Datasets utilizados no TK5

```text
HERC01.LIB.COBOL(PROG05)
HERC01.LIB.JCL(COMPILE5)
HERC01.LIB.JCL(EXEC5)
HERC01.PRIVLIB.LOAD(PROG05)

HERC01.CLIENTES.TXT
HERC01.TRANSAC.TXT
HERC01.CLIENTES.ORD
HERC01.TRANSAC.ORD
HERC01.ATUAL.TXT
HERC01.ERROS.TXT
```

---

## Etapas do JCL

O job de execução possui três etapas principais:

```text
SORTCLI
```

Ordena o arquivo de clientes pelo ID:

```jcl
SORT FIELDS=(1,5,CH,A)
```

```text
SORTTRX
```

Ordena as transações pelo ID do cliente e pelo ID da transação:

```jcl
SORT FIELDS=(1,5,CH,A,6,5,CH,A)
```

```text
RUNSTEP
```

Executa o módulo COBOL compilado e conecta os datasets por meio dos DDs:

```jcl
//CLIENTES DD DSN=HERC01.CLIENTES.ORD,DISP=SHR
//TRANSAC  DD DSN=HERC01.TRANSAC.ORD,DISP=SHR
//ATUAL    DD DSN=HERC01.ATUAL.TXT,DISP=OLD
//ERROS    DD DSN=HERC01.ERROS.TXT,DISP=OLD
//SAIDA    DD SYSOUT=*
```

---

## Resultado esperado

Uma execução bem-sucedida deve apresentar:

```text
COB       RC=0000
LKED      RC=0000
SORTCLI   RC=0000
SORTTRX   RC=0000
RUNSTEP   RC=0000
```

Além disso:

* todos os clientes devem aparecer no arquivo atualizado;
* os saldos devem refletir somente transações válidas;
* as transações inválidas devem aparecer em `ERROS.TXT`;
* as estatísticas devem corresponder aos dados processados.

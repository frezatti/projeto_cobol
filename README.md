# Projeto 7 COBOL - Consulta e Atualizacao de Clientes

## Nomes do projeto

- Transacao: `CLIE`
- Programa: `CLIPGM`
- Mapset: `CLISET`
- Map: `CLIMAP`
- Arquivo VSAM/File name: `CLIENTES`

## O que o sistema faz

O sistema permite consultar e atualizar clientes em uma tela online estilo CICS/KICKS.

Regras:

- `PF3`: sair da transacao.
- `PF5`: consultar cliente por codigo.
  - Encontrado: mostra `CLIENTE ENCONTRADO.`
  - Nao encontrado: mostra `CLIENTE NAO ENCONTRADO.`
- `PF6`: salvar alteracao.
  - Atualiza apenas telefone e cidade.
  - Sucesso: mostra `ALTERACAO REALIZADA.`

## Layout do registro VSAM

O PDF pede:

| Campo | Tamanho |
|---|---:|
| CODCLI | 6 |
| NOME | 30 |
| TELEFONE | 15 |
| CIDADE | 20 |

Total exigido: 71 bytes.

Nesta versao KICKS/TK5, o VSAM foi criado com `RECORDSIZE(80 80)`, seguindo o modelo do projeto de referencia. Por isso o COBOL tem `FILLER PIC X(09)` no fim do registro.

## Arquivos principais

| Arquivo | Funcao |
|---|---|
| `CLISET.bms` | Tela BMS em sintaxe KICKS: `KIKMSD`, `KIKMDI`, `KIKMDF` |
| `CLIPGM.cbl` | Programa COBOL KICKS principal |
| `jcl/VSAMCLIE.jcl` | Cria e carrega o VSAM `HERC01.CLIENTES.CLIE.KSDS` |
| `jcl/MAPCLIE.jcl` | Gera/compila o mapa `CLISET` |
| `jcl/BUILDCLIE.jcl` | Compila/linka o programa `CLIPGM` |
| `docs/FLUXOGRAMAS.md` | Fluxogramas do PF5 e PF6 |
| `reference_cics/` | Versao de referencia IBM CICS com `EXEC CICS` e macros `DFH*` |

## Ordem sugerida para usar no TK5/KICKS

1. Copiar `CLISET.bms` para `HERC01.PRIVLIB.SOURCE(CLISET)`.
2. Copiar `CLIPGM.cbl` para `HERC01.PRIVLIB.SOURCE(CLIPGM)`.
3. Rodar `jcl/VSAMCLIE.jcl` para criar e carregar o VSAM.
4. Rodar `jcl/MAPCLIE.jcl` para gerar o mapa.
5. Rodar `jcl/BUILDCLIE.jcl` para compilar/linkar o programa.
6. Configurar/confirmar o recurso KICKS/CICS file name `CLIENTES` apontando para `HERC01.CLIENTES.CLIE.KSDS`.
7. Configurar/confirmar a transacao `CLIE` apontando para o programa `CLIPGM`.
8. Executar a transacao `CLIE` no terminal.

## Observacao importante: KICKS vs IBM CICS

A versao principal foi feita para KICKS/TK5, baseada no projeto de referencia do colega:

- `EXEC KICKS`
- `KIKMSD`, `KIKMDI`, `KIKMDF`
- JCL com `KIKMAPS` e `K2KCOBCL`

A pasta `reference_cics/` mostra a equivalencia em IBM CICS real:

- `EXEC CICS`
- `DFHMSD`, `DFHMDI`, `DFHMDF`
- `COPY DFHAID`
- `DFHRESP(NOTFND)`
- `RETURN TRANSID('CLIE') COMMAREA(...)`

## Pontos importantes da logica

- O programa usa `EIBAID` para descobrir qual PF key o usuario pressionou.
- `PF5` faz leitura direta do VSAM pelo codigo do cliente.
- `PF6` faz `READ ... UPDATE` antes do `REWRITE`.
- O campo chave `CODCLI` nao e alterado no `REWRITE`.
- So `TELEFONE` e `CIDADE` sao alterados.
- O codigo do cliente e validado como obrigatorio e numerico.


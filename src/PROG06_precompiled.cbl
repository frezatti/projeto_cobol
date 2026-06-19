       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROG06.
       AUTHOR. ADRIEL FREZATTI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT ARQ-CLIENTES
               ASSIGN TO "data/CLIENTES.ORD"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT ARQ-TRANSACOES
               ASSIGN TO "data/TRANSACOES.ORD"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT ARQ-ERROS
               ASSIGN TO "out/ERROS.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT ARQ-SAIDA
               ASSIGN TO "out/SAIDA.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT ARQ-RELATORIO
               ASSIGN TO "out/RELATORIO_PROCESSAMENTO.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT ARQ-DETALHADO
               ASSIGN TO "out/RELATORIO_DETALHADO.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT ARQ-LOG
               ASSIGN TO "out/LOG_PROCESSAMENTO.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.

       FD  ARQ-CLIENTES
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 10 RECORDS
           RECORD CONTAINS 44 CHARACTERS
           DATA RECORD IS REG-CLIENTE.
       01  REG-CLIENTE.
           05 CLI-ID             PIC 9(05).
           05 CLI-NOME           PIC X(30).
           05 CLI-SALDO          PIC 9(09).

       FD  ARQ-TRANSACOES
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 10 RECORDS
           RECORD CONTAINS 20 CHARACTERS
           DATA RECORD IS REG-TRANSACAO.
       01  REG-TRANSACAO.
           05 TRX-CLI-ID         PIC 9(05).
           05 TRX-ID             PIC 9(05).
           05 TRX-TIPO           PIC X(01).
           05 TRX-VALOR          PIC 9(09).

       FD  ARQ-ERROS
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 10 RECORDS
           RECORD CONTAINS 120 CHARACTERS
           DATA RECORD IS REG-ERRO.
       01  REG-ERRO              PIC X(120).

       FD  ARQ-SAIDA
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 10 RECORDS
           RECORD CONTAINS 160 CHARACTERS
           DATA RECORD IS REG-SAIDA.
       01  REG-SAIDA             PIC X(160).

       FD  ARQ-RELATORIO
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 10 RECORDS
           RECORD CONTAINS 160 CHARACTERS
           DATA RECORD IS REG-RELATORIO.
       01  REG-RELATORIO         PIC X(160).

       FD  ARQ-DETALHADO
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 10 RECORDS
           RECORD CONTAINS 160 CHARACTERS
           DATA RECORD IS REG-DETALHADO.
       01  REG-DETALHADO         PIC X(160).

       FD  ARQ-LOG
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 10 RECORDS
           RECORD CONTAINS 160 CHARACTERS
           DATA RECORD IS REG-LOG.
       01  REG-LOG               PIC X(160).

       WORKING-STORAGE SECTION.

       01  SQLDA-ID pic 9(4) comp-5.
       01  SQLDSIZE pic 9(4) comp-5.
       01  SQL-STMT-ID pic 9(4) comp-5.
       01  SQLVAR-INDEX pic 9(4) comp-5.
       01  SQL-DATA-TYPE pic 9(4) comp-5.
       01  SQL-HOST-VAR-LENGTH pic 9(9) comp-5.
       01  SQL-S-HOST-VAR-LENGTH pic 9(9) comp-5.
       01  SQL-S-LITERAL pic X(258).
       01  SQL-LITERAL1 pic X(130).
       01  SQL-LITERAL2 pic X(130).
       01  SQL-LITERAL3 pic X(130).
       01  SQL-LITERAL4 pic X(130).
       01  SQL-LITERAL5 pic X(130).
       01  SQL-LITERAL6 pic X(130).
       01  SQL-LITERAL7 pic X(130).
       01  SQL-LITERAL8 pic X(130).
       01  SQL-LITERAL9 pic X(130).
       01  SQL-LITERAL10 pic X(130).
       01  SQL-IS-LITERAL pic 9(4) comp-5 value 1.
       01  SQL-IS-INPUT-HVAR pic 9(4) comp-5 value 2.
       01  SQL-CALL-TYPE pic 9(4) comp-5.
       01  SQL-SECTIONUMBER pic 9(4) comp-5.
       01  SQL-INPUT-SQLDA-ID pic 9(4) comp-5.
       01  SQL-OUTPUT-SQLDA-ID pic 9(4) comp-5.
       01  SQL-VERSION-NUMBER pic 9(4) comp-5.
       01  SQL-ARRAY-SIZE pic 9(4) comp-5.
       01  SQL-IS-STRUCT  pic 9(4) comp-5.
       01  SQL-IS-IND-STRUCT pic 9(4) comp-5.
       01  SQL-STRUCT-SIZE pic 9(4) comp-5.
       01  SQLA-PROGRAM-ID.
           05 SQL-PART1 pic 9(4) COMP-5 value 172.
           05 SQL-PART2 pic X(6) value "AEAWAI".
           05 SQL-PART3 pic X(24) value "lBvgTTGq01111 2         ".
           05 SQL-PART4 pic 9(4) COMP-5 value 8.
           05 SQL-PART5 pic X(8) value "DB2INST1".
           05 SQL-PART6 pic X(120) value LOW-VALUES.
           05 SQL-PART7 pic 9(4) COMP-5 value 8.
           05 SQL-PART8 pic X(8) value "PROG06  ".
           05 SQL-PART9 pic X(120) value LOW-VALUES.
                               

       
      *EXEC SQL 
      *INCLUDE SQLCA
      * END-EXEC
      * SQL Communication Area - SQLCA
       COPY 'sqlca.cbl'.

                

       01  WS-CONTROLE.
           05 WS-FIM-CLIENTES          PIC X VALUE "N".
              88 FIM-CLIENTES          VALUE "S".
              88 NAO-FIM-CLIENTES      VALUE "N".

           05 WS-FIM-TRANSACOES        PIC X VALUE "N".
              88 FIM-TRANSACOES        VALUE "S".
              88 NAO-FIM-TRANSACOES    VALUE "N".

           05 WS-STATUS-REGISTRO       PIC X(20) VALUE SPACES.
           05 WS-CONTEXTO-ERRO         PIC X VALUE SPACE.
              88 ERRO-CLIENTE          VALUE "C".
              88 ERRO-TRANSACAO        VALUE "T".

           05 WS-REG-DESDE-COMMIT      PIC 9(03) VALUE 0.

       01  WS-CONTADORES.
           05 WS-CLIENTES-LIDOS        PIC 9(06) VALUE 0.
           05 WS-CLIENTES-INSERIDOS    PIC 9(06) VALUE 0.
           05 WS-CLIENTES-ATUALIZADOS  PIC 9(06) VALUE 0.
           05 WS-CLIENTES-COM-ERRO     PIC 9(06) VALUE 0.

           05 WS-TRANSACOES-LIDAS      PIC 9(06) VALUE 0.
           05 WS-TRANSACOES-OK         PIC 9(06) VALUE 0.
           05 WS-TRANSACOES-COM-ERRO   PIC 9(06) VALUE 0.

           05 WS-CREDITOS-OK           PIC 9(06) VALUE 0.
           05 WS-DEBITOS-OK            PIC 9(06) VALUE 0.
           05 WS-ERROS-ENCONTRADOS     PIC 9(06) VALUE 0.

           05 WS-COMMITS               PIC 9(06) VALUE 0.
           05 WS-ROLLBACKS             PIC 9(06) VALUE 0.

       
      *EXEC SQL 
      *BEGIN DECLARE SECTION
      * END-EXEC.

       01  WS-DB-CLI-ID             PIC S9(09) COMP-5.
       01  WS-DB-CLI-NOME           PIC X(30).
       01  WS-DB-CLI-SALDO          PIC S9(09) COMP-3.
       01  WS-DB-TRX-ID             PIC S9(09) COMP-5.
       01  WS-DB-TRX-TIPO           PIC X(01).
       01  WS-DB-TRX-VALOR          PIC S9(09) COMP-3.
       01  WS-DB-SALDO-ATUAL        PIC S9(09) COMP-3.
       01  WS-DESCRICAO-ERRO        PIC X(100).

       
      *EXEC SQL
      *     END DECLARE SECTION
      * END-EXEC
                

       01  WS-SQLCODE-DISPLAY       PIC -999999.

       PROCEDURE DIVISION.

       0000-PRINCIPAL.

           PERFORM 1000-INICIALIZAR
              THRU 1000-INICIALIZAR-FIM.

           PERFORM 2000-PROCESSAR-CLIENTES
              THRU 2000-PROCESSAR-CLIENTES-FIM.

           PERFORM 3000-PROCESSAR-TRANSACOES
              THRU 3000-PROCESSAR-TRANSACOES-FIM.

           PERFORM 8000-GERAR-RELATORIOS
              THRU 8000-GERAR-RELATORIOS-FIM.

           PERFORM 9000-FINALIZAR
              THRU 9000-FINALIZAR-FIM.

           STOP RUN.

       1000-INICIALIZAR.

           SET NAO-FIM-CLIENTES TO TRUE.
           SET NAO-FIM-TRANSACOES TO TRUE.
           MOVE 0 TO WS-REG-DESDE-COMMIT.

           OPEN INPUT  ARQ-CLIENTES
                INPUT  ARQ-TRANSACOES
                OUTPUT ARQ-ERROS
                OUTPUT ARQ-SAIDA
                OUTPUT ARQ-RELATORIO
                OUTPUT ARQ-DETALHADO
                OUTPUT ARQ-LOG.

           PERFORM 1200-CONECTAR-DB
              THRU 1200-CONECTAR-DB-FIM.

           MOVE "INICIO DO PROCESSAMENTO" TO REG-LOG.
           WRITE REG-LOG.

       1000-INICIALIZAR-FIM.
           EXIT.

       1200-CONECTAR-DB.

           
      *EXEC SQL 
      *CONNECT TO BANCO
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 1 TO SQL-STMT-ID 
           MOVE 1 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE "BANCO"
            TO SQL-LITERAL1
           MOVE 5 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE SQL-LITERAL1
            BY VALUE 0
                     0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 4 TO SQL-SECTIONUMBER 
           MOVE 29 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                   .

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO WS-SQLCODE-DISPLAY
              MOVE SPACES TO REG-LOG
              STRING "ERRO AO CONECTAR DB2. SQLCODE="
                     WS-SQLCODE-DISPLAY
                DELIMITED BY SIZE INTO REG-LOG
              WRITE REG-LOG
              STOP RUN
           END-IF.

           MOVE "CONECTADO AO DB2 COM SUCESSO" TO REG-LOG.
           WRITE REG-LOG.

       1200-CONECTAR-DB-FIM.
           EXIT.

       2000-PROCESSAR-CLIENTES.

           MOVE "INICIO DO PROCESSAMENTO DE CLIENTES" TO REG-LOG.
           WRITE REG-LOG.

           PERFORM 2100-LER-CLIENTE
              THRU 2100-LER-CLIENTE-FIM.

           PERFORM UNTIL FIM-CLIENTES

              SET ERRO-CLIENTE TO TRUE
              PERFORM 2200-VALIDAR-CLIENTE
                 THRU 2200-VALIDAR-CLIENTE-FIM

              IF WS-STATUS-REGISTRO = "OK"
                 PERFORM 2300-GRAVAR-CLIENTE-DB
                    THRU 2300-GRAVAR-CLIENTE-DB-FIM
              END-IF

              PERFORM 5100-VERIFICAR-COMMIT
                 THRU 5100-VERIFICAR-COMMIT-FIM

              PERFORM 2100-LER-CLIENTE
                 THRU 2100-LER-CLIENTE-FIM

           END-PERFORM.

           MOVE "FIM DO PROCESSAMENTO DE CLIENTES" TO REG-LOG.
           WRITE REG-LOG.

       2000-PROCESSAR-CLIENTES-FIM.
           EXIT.

       2100-LER-CLIENTE.

           READ ARQ-CLIENTES
              AT END
                 SET FIM-CLIENTES TO TRUE
              NOT AT END
                 ADD 1 TO WS-CLIENTES-LIDOS
           END-READ.

       2100-LER-CLIENTE-FIM.
           EXIT.

       2200-VALIDAR-CLIENTE.

           MOVE "OK" TO WS-STATUS-REGISTRO.
           MOVE SPACES TO WS-DESCRICAO-ERRO.

           IF CLI-NOME = SPACES
              MOVE "ERRO" TO WS-STATUS-REGISTRO
              MOVE "NOME OBRIGATORIO" TO WS-DESCRICAO-ERRO
              ADD 1 TO WS-CLIENTES-COM-ERRO
              PERFORM 4100-GRAVAR-ERRO-ARQUIVO
                 THRU 4100-GRAVAR-ERRO-ARQUIVO-FIM
              PERFORM 4200-GRAVAR-ERRO-DB
                 THRU 4200-GRAVAR-ERRO-DB-FIM
           END-IF.

       2200-VALIDAR-CLIENTE-FIM.
           EXIT.

       2300-GRAVAR-CLIENTE-DB.

           MOVE CLI-ID    TO WS-DB-CLI-ID.
           MOVE CLI-NOME  TO WS-DB-CLI-NOME.
           MOVE CLI-SALDO TO WS-DB-CLI-SALDO.

           
      *EXEC SQL 
      *SELECT CLI_SALDO
      *           INTO :WS-DB-SALDO-ATUAL
      *           FROM CLIENTES
      *          WHERE CLI_ID = :WS-DB-CLI-ID
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 2 TO SQL-STMT-ID 
           MOVE 1 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 496 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-ID
            BY VALUE 0
                     0

           MOVE 3 TO SQL-STMT-ID 
           MOVE 1 TO SQLDSIZE 
           MOVE 3 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 9 TO SQL-HOST-VAR-LENGTH
           MOVE 484 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-SALDO-ATUAL
            BY VALUE 0
                     0

           MOVE 3 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 1 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                   .

           EVALUATE TRUE

              WHEN SQLCODE = 0

                 
      *EXEC SQL 
      *UPDATE CLIENTES
      *                  SET CLI_NOME = :WS-DB-CLI-NOME,
      *                      CLI_SALDO = :WS-DB-CLI-SALDO,
      *                      DT_ATUALIZACAO = CURRENT DATE
      *                WHERE CLI_ID = :WS-DB-CLI-ID
      *           END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 4 TO SQL-STMT-ID 
           MOVE 3 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 30 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-NOME
            BY VALUE 0
                     0

           MOVE 9 TO SQL-HOST-VAR-LENGTH
           MOVE 484 TO SQL-DATA-TYPE
           MOVE 1 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-SALDO
            BY VALUE 0
                     0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 496 TO SQL-DATA-TYPE
           MOVE 2 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-ID
            BY VALUE 0
                     0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 2 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                                                                        

                 IF SQLCODE = 0
                    ADD 1 TO WS-CLIENTES-ATUALIZADOS
                    MOVE "CLIENTE ATUALIZADO" TO WS-STATUS-REGISTRO
                    PERFORM 3650-GRAVAR-STATUS-CLIENTE
                       THRU 3650-GRAVAR-STATUS-CLIENTE-FIM
                 ELSE
                    MOVE "ERRO DB2 AO ATUALIZAR CLIENTE"
                      TO WS-DESCRICAO-ERRO
                    PERFORM 7000-TRATAR-ERRO-SQL
                       THRU 7000-TRATAR-ERRO-SQL-FIM
                 END-IF

              WHEN SQLCODE = 100

                 
      *EXEC SQL 
      *INSERT INTO CLIENTES
      *                   (CLI_ID, CLI_NOME, CLI_SALDO, DT_ATUALIZACAO)
      *               VALUES
      *                   (:WS-DB-CLI-ID,
      *                    :WS-DB-CLI-NOME,
      *                    :WS-DB-CLI-SALDO,
      *                    CURRENT DATE)
      *           END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 5 TO SQL-STMT-ID 
           MOVE 3 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 496 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-ID
            BY VALUE 0
                     0

           MOVE 30 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 1 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-NOME
            BY VALUE 0
                     0

           MOVE 9 TO SQL-HOST-VAR-LENGTH
           MOVE 484 TO SQL-DATA-TYPE
           MOVE 2 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-SALDO
            BY VALUE 0
                     0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 3 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                                                                        

                 IF SQLCODE = 0
                    ADD 1 TO WS-CLIENTES-INSERIDOS
                    MOVE "CLIENTE INSERIDO" TO WS-STATUS-REGISTRO
                    PERFORM 3650-GRAVAR-STATUS-CLIENTE
                       THRU 3650-GRAVAR-STATUS-CLIENTE-FIM
                 ELSE
                    MOVE "ERRO DB2 AO INSERIR CLIENTE"
                      TO WS-DESCRICAO-ERRO
                    PERFORM 7000-TRATAR-ERRO-SQL
                       THRU 7000-TRATAR-ERRO-SQL-FIM
                 END-IF

              WHEN OTHER

                 MOVE "ERRO DB2 AO BUSCAR CLIENTE"
                   TO WS-DESCRICAO-ERRO
                 PERFORM 7000-TRATAR-ERRO-SQL
                    THRU 7000-TRATAR-ERRO-SQL-FIM

           END-EVALUATE.

       2300-GRAVAR-CLIENTE-DB-FIM.
           EXIT.

       3000-PROCESSAR-TRANSACOES.

           MOVE "INICIO DO PROCESSAMENTO DE TRANSACOES" TO REG-LOG.
           WRITE REG-LOG.

           PERFORM 3100-LER-TRANSACAO
              THRU 3100-LER-TRANSACAO-FIM.

           PERFORM UNTIL FIM-TRANSACOES

              SET ERRO-TRANSACAO TO TRUE
              PERFORM 3200-VALIDAR-TRANSACAO
                 THRU 3200-VALIDAR-TRANSACAO-FIM

              IF WS-STATUS-REGISTRO = "OK"
                 PERFORM 3300-BUSCAR-CLIENTE-DB
                    THRU 3300-BUSCAR-CLIENTE-DB-FIM
              END-IF

              IF WS-STATUS-REGISTRO = "OK"
                 PERFORM 3400-GRAVAR-TRANSACAO-DB
                    THRU 3400-GRAVAR-TRANSACAO-DB-FIM
              END-IF

              IF WS-STATUS-REGISTRO = "OK"
                 PERFORM 3500-ATUALIZAR-SALDO-DB
                    THRU 3500-ATUALIZAR-SALDO-DB-FIM
              END-IF

              PERFORM 5100-VERIFICAR-COMMIT
                 THRU 5100-VERIFICAR-COMMIT-FIM

              PERFORM 3100-LER-TRANSACAO
                 THRU 3100-LER-TRANSACAO-FIM

           END-PERFORM.

           MOVE "FIM DO PROCESSAMENTO DE TRANSACOES" TO REG-LOG.
           WRITE REG-LOG.

       3000-PROCESSAR-TRANSACOES-FIM.
           EXIT.

       3100-LER-TRANSACAO.

           READ ARQ-TRANSACOES
              AT END
                 SET FIM-TRANSACOES TO TRUE
              NOT AT END
                 ADD 1 TO WS-TRANSACOES-LIDAS
           END-READ.

       3100-LER-TRANSACAO-FIM.
           EXIT.

       3200-VALIDAR-TRANSACAO.

           MOVE "OK" TO WS-STATUS-REGISTRO.
           MOVE SPACES TO WS-DESCRICAO-ERRO.

           IF TRX-TIPO NOT = "C" AND TRX-TIPO NOT = "D"
              MOVE "ERRO" TO WS-STATUS-REGISTRO
              MOVE "TIPO DE TRANSACAO INVALIDO"
                TO WS-DESCRICAO-ERRO
              ADD 1 TO WS-TRANSACOES-COM-ERRO
              PERFORM 4100-GRAVAR-ERRO-ARQUIVO
                 THRU 4100-GRAVAR-ERRO-ARQUIVO-FIM
              PERFORM 4200-GRAVAR-ERRO-DB
                 THRU 4200-GRAVAR-ERRO-DB-FIM
           END-IF.

           IF WS-STATUS-REGISTRO = "OK"
              IF TRX-VALOR = 0
                 MOVE "ERRO" TO WS-STATUS-REGISTRO
                 MOVE "VALOR DE TRANSACAO ZERADO"
                   TO WS-DESCRICAO-ERRO
                 ADD 1 TO WS-TRANSACOES-COM-ERRO
                 PERFORM 4100-GRAVAR-ERRO-ARQUIVO
                    THRU 4100-GRAVAR-ERRO-ARQUIVO-FIM
                 PERFORM 4200-GRAVAR-ERRO-DB
                    THRU 4200-GRAVAR-ERRO-DB-FIM
              END-IF
           END-IF.

       3200-VALIDAR-TRANSACAO-FIM.
           EXIT.

       3300-BUSCAR-CLIENTE-DB.

           MOVE TRX-CLI-ID TO WS-DB-CLI-ID.

           
      *EXEC SQL 
      *SELECT CLI_SALDO
      *           INTO :WS-DB-SALDO-ATUAL
      *           FROM CLIENTES
      *          WHERE CLI_ID = :WS-DB-CLI-ID
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 6 TO SQL-STMT-ID 
           MOVE 1 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 496 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-ID
            BY VALUE 0
                     0

           MOVE 7 TO SQL-STMT-ID 
           MOVE 1 TO SQLDSIZE 
           MOVE 3 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 9 TO SQL-HOST-VAR-LENGTH
           MOVE 484 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-SALDO-ATUAL
            BY VALUE 0
                     0

           MOVE 3 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 4 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                   .

           EVALUATE TRUE

              WHEN SQLCODE = 0

                 IF TRX-TIPO = "D"
                    IF WS-DB-SALDO-ATUAL < TRX-VALOR
                       MOVE "ERRO" TO WS-STATUS-REGISTRO
                       MOVE "SALDO INSUFICIENTE"
                         TO WS-DESCRICAO-ERRO
                       ADD 1 TO WS-TRANSACOES-COM-ERRO
                       PERFORM 4100-GRAVAR-ERRO-ARQUIVO
                          THRU 4100-GRAVAR-ERRO-ARQUIVO-FIM
                       PERFORM 4200-GRAVAR-ERRO-DB
                          THRU 4200-GRAVAR-ERRO-DB-FIM
                    END-IF
                 END-IF

              WHEN SQLCODE = 100

                 MOVE "ERRO" TO WS-STATUS-REGISTRO
                 MOVE "CLIENTE INEXISTENTE"
                   TO WS-DESCRICAO-ERRO
                 ADD 1 TO WS-TRANSACOES-COM-ERRO
                 PERFORM 4100-GRAVAR-ERRO-ARQUIVO
                    THRU 4100-GRAVAR-ERRO-ARQUIVO-FIM
                 PERFORM 4200-GRAVAR-ERRO-DB
                    THRU 4200-GRAVAR-ERRO-DB-FIM

              WHEN OTHER

                 MOVE "ERRO DB2 AO BUSCAR CLIENTE"
                   TO WS-DESCRICAO-ERRO
                 PERFORM 7000-TRATAR-ERRO-SQL
                    THRU 7000-TRATAR-ERRO-SQL-FIM

           END-EVALUATE.

       3300-BUSCAR-CLIENTE-DB-FIM.
           EXIT.

       3400-GRAVAR-TRANSACAO-DB.

           MOVE TRX-ID     TO WS-DB-TRX-ID.
           MOVE TRX-CLI-ID TO WS-DB-CLI-ID.
           MOVE TRX-TIPO   TO WS-DB-TRX-TIPO.
           MOVE TRX-VALOR  TO WS-DB-TRX-VALOR.

           
      *EXEC SQL 
      *INSERT INTO TRANSACOES
      *             (TRX_ID, CLI_ID, TRX_TIPO,
      *              TRX_VALOR, DT_PROCESSAMENTO)
      *         VALUES
      *             (:WS-DB-TRX-ID,
      *              :WS-DB-CLI-ID,
      *              :WS-DB-TRX-TIPO,
      *              :WS-DB-TRX-VALOR,
      *              CURRENT DATE)
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 8 TO SQL-STMT-ID 
           MOVE 4 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 496 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-TRX-ID
            BY VALUE 0
                     0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 496 TO SQL-DATA-TYPE
           MOVE 1 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-ID
            BY VALUE 0
                     0

           MOVE 1 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 2 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-TRX-TIPO
            BY VALUE 0
                     0

           MOVE 9 TO SQL-HOST-VAR-LENGTH
           MOVE 484 TO SQL-DATA-TYPE
           MOVE 3 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-TRX-VALOR
            BY VALUE 0
                     0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 5 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                   .

           IF SQLCODE NOT = 0
              MOVE "ERRO DB2 AO INSERIR TRANSACAO"
                TO WS-DESCRICAO-ERRO
              PERFORM 7000-TRATAR-ERRO-SQL
                 THRU 7000-TRATAR-ERRO-SQL-FIM
           END-IF.

       3400-GRAVAR-TRANSACAO-DB-FIM.
           EXIT.

       3500-ATUALIZAR-SALDO-DB.

           MOVE TRX-CLI-ID TO WS-DB-CLI-ID.
           MOVE TRX-VALOR  TO WS-DB-TRX-VALOR.

           IF TRX-TIPO = "C"
              
      *EXEC SQL 
      *UPDATE CLIENTES
      *               SET CLI_SALDO = CLI_SALDO + :WS-DB-TRX-VALOR,
      *                   DT_ATUALIZACAO = CURRENT DATE
      *             WHERE CLI_ID = :WS-DB-CLI-ID
      *        END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 9 TO SQL-STMT-ID 
           MOVE 2 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 9 TO SQL-HOST-VAR-LENGTH
           MOVE 484 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-TRX-VALOR
            BY VALUE 0
                     0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 496 TO SQL-DATA-TYPE
           MOVE 1 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-ID
            BY VALUE 0
                     0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 6 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                                                                        

              IF SQLCODE = 0
                 ADD 1 TO WS-CREDITOS-OK
                 ADD 1 TO WS-TRANSACOES-OK
                 MOVE "CREDITO PROCESSADO" TO WS-STATUS-REGISTRO
                 PERFORM 3600-GRAVAR-STATUS-TRANSACAO
                    THRU 3600-GRAVAR-STATUS-TRANSACAO-FIM
              ELSE
                 MOVE "ERRO DB2 AO ATUALIZAR CREDITO"
                   TO WS-DESCRICAO-ERRO
                 PERFORM 7000-TRATAR-ERRO-SQL
                    THRU 7000-TRATAR-ERRO-SQL-FIM
              END-IF
           END-IF.

           IF TRX-TIPO = "D"
              
      *EXEC SQL 
      *UPDATE CLIENTES
      *               SET CLI_SALDO = CLI_SALDO - :WS-DB-TRX-VALOR,
      *                   DT_ATUALIZACAO = CURRENT DATE
      *             WHERE CLI_ID = :WS-DB-CLI-ID
      *        END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 10 TO SQL-STMT-ID 
           MOVE 2 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 9 TO SQL-HOST-VAR-LENGTH
           MOVE 484 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-TRX-VALOR
            BY VALUE 0
                     0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 496 TO SQL-DATA-TYPE
           MOVE 1 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-ID
            BY VALUE 0
                     0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 7 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                                                                        

              IF SQLCODE = 0
                 ADD 1 TO WS-DEBITOS-OK
                 ADD 1 TO WS-TRANSACOES-OK
                 MOVE "DEBITO PROCESSADO" TO WS-STATUS-REGISTRO
                 PERFORM 3600-GRAVAR-STATUS-TRANSACAO
                    THRU 3600-GRAVAR-STATUS-TRANSACAO-FIM
              ELSE
                 MOVE "ERRO DB2 AO ATUALIZAR DEBITO"
                   TO WS-DESCRICAO-ERRO
                 PERFORM 7000-TRATAR-ERRO-SQL
                    THRU 7000-TRATAR-ERRO-SQL-FIM
              END-IF
           END-IF.

       3500-ATUALIZAR-SALDO-DB-FIM.
           EXIT.

       3600-GRAVAR-STATUS-TRANSACAO.

           MOVE SPACES TO REG-SAIDA.
           STRING
              "TRANSACAO | CLIENTE=" TRX-CLI-ID
              " | TRX=" TRX-ID
              " | TIPO=" TRX-TIPO
              " | VALOR=" TRX-VALOR
              " | STATUS=" WS-STATUS-REGISTRO
              DELIMITED BY SIZE
              INTO REG-SAIDA
           END-STRING.
           WRITE REG-SAIDA.

           MOVE REG-SAIDA TO REG-DETALHADO.
           WRITE REG-DETALHADO.

       3600-GRAVAR-STATUS-TRANSACAO-FIM.
           EXIT.

       3650-GRAVAR-STATUS-CLIENTE.

           MOVE SPACES TO REG-SAIDA.
           STRING
              "CLIENTE | ID=" CLI-ID
              " | NOME=" CLI-NOME
              " | SALDO=" CLI-SALDO
              " | STATUS=" WS-STATUS-REGISTRO
              DELIMITED BY SIZE
              INTO REG-SAIDA
           END-STRING.
           WRITE REG-SAIDA.

           MOVE REG-SAIDA TO REG-DETALHADO.
           WRITE REG-DETALHADO.

       3650-GRAVAR-STATUS-CLIENTE-FIM.
           EXIT.

       4100-GRAVAR-ERRO-ARQUIVO.

           ADD 1 TO WS-ERROS-ENCONTRADOS.
           MOVE SPACES TO REG-ERRO.

           IF ERRO-TRANSACAO
              STRING
                 "ERRO: " WS-DESCRICAO-ERRO
                 " - CLI_ID " TRX-CLI-ID
                 " - TRX_ID " TRX-ID
                 DELIMITED BY SIZE
                 INTO REG-ERRO
              END-STRING
           ELSE
              STRING
                 "ERRO: " WS-DESCRICAO-ERRO
                 " - CLI_ID " CLI-ID
                 DELIMITED BY SIZE
                 INTO REG-ERRO
              END-STRING
           END-IF.

           WRITE REG-ERRO.

           MOVE REG-ERRO TO REG-DETALHADO.
           WRITE REG-DETALHADO.

       4100-GRAVAR-ERRO-ARQUIVO-FIM.
           EXIT.

       4200-GRAVAR-ERRO-DB.

           IF ERRO-TRANSACAO
              MOVE TRX-CLI-ID TO WS-DB-CLI-ID
           ELSE
              MOVE CLI-ID TO WS-DB-CLI-ID
           END-IF.

           
      *EXEC SQL 
      *INSERT INTO ERROS_PROCESSAMENTO
      *             (CLI_ID, DESCRICAO_ERRO, DT_OCORRENCIA)
      *         VALUES
      *             (:WS-DB-CLI-ID,
      *              :WS-DESCRICAO-ERRO,
      *              CURRENT TIMESTAMP)
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 11 TO SQL-STMT-ID 
           MOVE 2 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 496 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DB-CLI-ID
            BY VALUE 0
                     0

           MOVE 100 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 1 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-DESCRICAO-ERRO
            BY VALUE 0
                     0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 8 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                   .

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO WS-SQLCODE-DISPLAY
              MOVE SPACES TO REG-LOG
              STRING
                 "FALHA AO INSERIR ERRO NO DB2. SQLCODE="
                 WS-SQLCODE-DISPLAY
                 DELIMITED BY SIZE INTO REG-LOG
              END-STRING
              WRITE REG-LOG
           END-IF.

       4200-GRAVAR-ERRO-DB-FIM.
           EXIT.

       5100-VERIFICAR-COMMIT.

           ADD 1 TO WS-REG-DESDE-COMMIT.

           IF WS-REG-DESDE-COMMIT >= 100
              PERFORM 5200-EXECUTAR-COMMIT
                 THRU 5200-EXECUTAR-COMMIT-FIM
           END-IF.

       5100-VERIFICAR-COMMIT-FIM.
           EXIT.

       5200-EXECUTAR-COMMIT.

           
      *EXEC SQL 
      *COMMIT
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 0 TO SQL-INPUT-SQLDA-ID 
           MOVE 0 TO SQL-SECTIONUMBER 
           MOVE 21 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                   .

           IF SQLCODE = 0
              ADD 1 TO WS-COMMITS
              MOVE 0 TO WS-REG-DESDE-COMMIT
              MOVE "COMMIT EXECUTADO" TO REG-LOG
              WRITE REG-LOG
           ELSE
              MOVE "ERRO DB2 AO EXECUTAR COMMIT"
                TO WS-DESCRICAO-ERRO
              PERFORM 7000-TRATAR-ERRO-SQL
                 THRU 7000-TRATAR-ERRO-SQL-FIM
           END-IF.

       5200-EXECUTAR-COMMIT-FIM.
           EXIT.

       5300-EXECUTAR-ROLLBACK.

           
      *EXEC SQL 
      *ROLLBACK
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 0 TO SQL-INPUT-SQLDA-ID 
           MOVE 0 TO SQL-SECTIONUMBER 
           MOVE 28 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                   .

           ADD 1 TO WS-ROLLBACKS.
           MOVE 0 TO WS-REG-DESDE-COMMIT.

           MOVE "ROLLBACK EXECUTADO" TO REG-LOG.
           WRITE REG-LOG.

       5300-EXECUTAR-ROLLBACK-FIM.
           EXIT.

       7000-TRATAR-ERRO-SQL.

           MOVE SQLCODE TO WS-SQLCODE-DISPLAY.

           MOVE SPACES TO REG-LOG.
           STRING
              WS-DESCRICAO-ERRO
              " SQLCODE="
              WS-SQLCODE-DISPLAY
              DELIMITED BY SIZE
              INTO REG-LOG
           END-STRING.
           WRITE REG-LOG.

           PERFORM 5300-EXECUTAR-ROLLBACK
              THRU 5300-EXECUTAR-ROLLBACK-FIM.

           MOVE "ERRO" TO WS-STATUS-REGISTRO.
           ADD 1 TO WS-ERROS-ENCONTRADOS.

       7000-TRATAR-ERRO-SQL-FIM.
           EXIT.

       8000-GERAR-RELATORIOS.

           MOVE "****************************************"
             TO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE "RELATORIO DE PROCESSAMENTO"
             TO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE "****************************************"
             TO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "CLIENTES LIDOS.........: "
                  WS-CLIENTES-LIDOS
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "CLIENTES INSERIDOS.....: "
                  WS-CLIENTES-INSERIDOS
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "CLIENTES ATUALIZADOS...: "
                  WS-CLIENTES-ATUALIZADOS
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "CLIENTES COM ERRO......: "
                  WS-CLIENTES-COM-ERRO
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "TRANSACOES LIDAS.......: "
                  WS-TRANSACOES-LIDAS
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "TRANSACOES PROCESSADAS.: "
                  WS-TRANSACOES-OK
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "TRANSACOES COM ERRO....: "
                  WS-TRANSACOES-COM-ERRO
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "CREDITOS PROCESSADOS...: "
                  WS-CREDITOS-OK
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "DEBITOS PROCESSADOS....: "
                  WS-DEBITOS-OK
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "ERROS ENCONTRADOS......: "
                  WS-ERROS-ENCONTRADOS
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "COMMITS EXECUTADOS.....: "
                  WS-COMMITS
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE SPACES TO REG-RELATORIO.
           STRING "ROLLBACKS EXECUTADOS...: "
                  WS-ROLLBACKS
             DELIMITED BY SIZE INTO REG-RELATORIO.
           WRITE REG-RELATORIO.

           MOVE "FIM DO RELATORIO"
             TO REG-RELATORIO.
           WRITE REG-RELATORIO.

       8000-GERAR-RELATORIOS-FIM.
           EXIT.

       9000-FINALIZAR.

           IF WS-REG-DESDE-COMMIT > 0
              PERFORM 5200-EXECUTAR-COMMIT
                 THRU 5200-EXECUTAR-COMMIT-FIM
           END-IF.

           
      *EXEC SQL 
      *CONNECT RESET
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 0 TO SQL-INPUT-SQLDA-ID 
           MOVE 3 TO SQL-SECTIONUMBER 
           MOVE 29 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                   .

           MOVE "FIM DO PROCESSAMENTO" TO REG-LOG.
           WRITE REG-LOG.

           CLOSE ARQ-CLIENTES
                 ARQ-TRANSACOES
                 ARQ-ERROS
                 ARQ-SAIDA
                 ARQ-RELATORIO
                 ARQ-DETALHADO
                 ARQ-LOG.

       9000-FINALIZAR-FIM.
           EXIT.

CREATE DATABASE HelpBox2;
USE HelpBox2;

-- Tabela genérica de users
CREATE TABLE Usuario (
    id_Usuario INT IDENTITY(1,1) PRIMARY KEY,
    email_Usuario VARCHAR(30) UNIQUE,
    senha_Usuario VARCHAR(14),
    cargo_Usuario VARCHAR(20),
    departamento_Usuario VARCHAR(20),
    nivelAcesso_Usuario INT,  -- 1 = Cliente | 2 = Técnico | 3 = ADM
    nome_Usuario VARCHAR(20),
    sobrenome_Usuario VARCHAR(30));

-- Tabelas de cada user
CREATE TABLE Tecnico (
    fk_Usuario_id_Usuario INT PRIMARY KEY,
    CONSTRAINT FK_Tecnico_Usuario FOREIGN KEY (fk_Usuario_id_Usuario)
        REFERENCES Usuario(id_Usuario)
        ON DELETE CASCADE);

CREATE TABLE Cliente (
    fk_Usuario_id_Usuario INT PRIMARY KEY,
    CONSTRAINT FK_Cliente_Usuario FOREIGN KEY (fk_Usuario_id_Usuario)
        REFERENCES Usuario(id_Usuario)
        ON DELETE CASCADE);

CREATE TABLE ADM (
    fk_Usuario_id_Usuario INT PRIMARY KEY,
    CONSTRAINT FK_ADM_Usuario FOREIGN KEY (fk_Usuario_id_Usuario)
        REFERENCES Usuario(id_Usuario)
        ON DELETE CASCADE);

-- Outras tables

CREATE TABLE Chamado (
    id_Cham INT IDENTITY(1,1) PRIMARY KEY,
    status_Cham VARCHAR(50),
    dataAbertura_Cham DATE,
    dataFechamento_Cham DATE,
    prioridade_Cham CHAR(1),
    categoria_Cham VARCHAR(50),
    solucaoIA_Cham VARCHAR(200),
    solucaoTec_Cham VARCHAR(200),
    descricao_Cham VARCHAR(200),
    solucaoFinal_Cham VARCHAR(200),
    tecResponsavel_Cham VARCHAR(100),
    dataProblema DATE,
    fk_Cliente_fk_Usuario_id_Usuario INT,
    fk_Tecnico_fk_Usuario_id_Usuario INT,
    fk_ADM_fk_Usuario_id_Usuario INT,
    CONSTRAINT FK_Chamado_Cliente FOREIGN KEY (fk_Cliente_fk_Usuario_id_Usuario)
        REFERENCES Cliente(fk_Usuario_id_Usuario),
    CONSTRAINT FK_Chamado_Tecnico FOREIGN KEY (fk_Tecnico_fk_Usuario_id_Usuario)
        REFERENCES Tecnico(fk_Usuario_id_Usuario),
    CONSTRAINT FK_Chamado_ADM FOREIGN KEY (fk_ADM_fk_Usuario_id_Usuario)
        REFERENCES ADM(fk_Usuario_id_Usuario)
		);

CREATE TABLE Relatorio (
    id_Cham INT PRIMARY KEY,
    relatorio VARCHAR(500),
    fk_ADM_fk_Usuario_id_Usuario INT,
    CONSTRAINT FK_Relatorio_ADM FOREIGN KEY (fk_ADM_fk_Usuario_id_Usuario)
        REFERENCES ADM(fk_Usuario_id_Usuario)
        ON DELETE CASCADE,
    CONSTRAINT FK_Relatorio_Chamado FOREIGN KEY (id_Cham)
        REFERENCES Chamado(id_Cham)
        ON DELETE CASCADE);

-- Script do trigger
CREATE TRIGGER trg_InsertTipoUsuario
ON Usuario
AFTER INSERT
AS
BEGIN
    INSERT INTO ADM (fk_Usuario_id_Usuario)
    SELECT id_Usuario FROM inserted WHERE nivelAcesso_Usuario = 3;

    INSERT INTO Tecnico (fk_Usuario_id_Usuario)
    SELECT id_Usuario FROM inserted WHERE nivelAcesso_Usuario = 2;

    INSERT INTO Cliente (fk_Usuario_id_Usuario)
    SELECT id_Usuario FROM inserted WHERE nivelAcesso_Usuario = 1;
END;

-- Inserir usuários
INSERT INTO Usuario (email_Usuario, senha_Usuario, cargo_Usuario, departamento_Usuario, 
nivelAcesso_Usuario, nome_Usuario, sobrenome_Usuario) 
VALUES ('guilherme@email.com', 'senha123', 'Administrador', 'TI', 3, 'Guilherme', 'Silva');

INSERT INTO Usuario (email_Usuario, senha_Usuario, cargo_Usuario, departamento_Usuario, 
nivelAcesso_Usuario, nome_Usuario, sobrenome_Usuario) 
VALUES ('agatha@email.com', 'senha456', 'Técnica', 'Suporte', 2, 'Agatha', 'Souza');

INSERT INTO Usuario (email_Usuario, senha_Usuario, cargo_Usuario, departamento_Usuario, 
nivelAcesso_Usuario, nome_Usuario, sobrenome_Usuario) 
VALUES ('vanessa@email.com', 'senha789', 'Cliente', 'Financeiro', 1, 'Vanessa', 'Lima');

INSERT INTO Usuario (email_Usuario, senha_Usuario, cargo_Usuario, departamento_Usuario, 
nivelAcesso_Usuario, nome_Usuario, sobrenome_Usuario) 
VALUES ('jota@email.com', 'senha147', 'Cliente', 'Atendente', 1, 'João', 'Lucas');

INSERT INTO Chamado (
    status_Cham,
    dataAbertura_Cham,
    datafechamento_Cham,
    prioridade_Cham,
    categoria_Cham,
    solucaoIA_Cham,
    solucaoTec_Cham,
    descricao_Cham,
    solucaoFinal_Cham,
    tecResponsavel_Cham,
    dataProblema,
    fk_Cliente_fk_Usuario_id_Usuario,
    fk_Tecnico_fk_Usuario_id_Usuario,
    fk_ADM_FK_Usuario_id_Usuario
)
VALUES ('Aberto','2025-05-18',NULL,'A','Software','Reiniciar o PC','Desinstalar e instalar o app'
, 'Erro ao acessar o sistema' ,'Desinstalar e instalar o app',
'Agatha Souza','2025-05-17',3,2,1);

-- Views para facilitar consultas

CREATE VIEW vw_Clientes_Completos AS
SELECT Usuario.*
FROM Cliente
JOIN Usuario ON Cliente.fk_Usuario_id_Usuario = Usuario.id_Usuario;

CREATE VIEW vw_Tecnicos_Completos AS
SELECT Usuario.*
FROM Tecnico
JOIN Usuario ON Tecnico.fk_Usuario_id_Usuario = Usuario.id_Usuario;

CREATE VIEW vw_ADMs_Completos AS
SELECT Usuario.*
FROM ADM
JOIN Usuario ON ADM.fk_Usuario_id_Usuario = Usuario.id_Usuario;


CREATE VIEW vw_Chamados_Visualizacao AS
SELECT
    id_Cham AS [ID do Chamado],
    status_Cham AS [Status],
    dataAbertura_Cham AS [Data de Abertura],
    datafechamento_Cham AS [Data de Fechamento],
    prioridade_Cham AS [Prioridade],
    categoria_Cham AS [Categoria],
    solucaoIA_Cham AS [Solução IA],
    solucaoTec_Cham AS [Solução Técnica],
    descricao_Cham AS [Descrição],
    solucaoFinal_Cham AS [Solução Final],
    tecResponsavel_Cham AS [Técnico Responsável],
    dataProblema AS [Data do Problema],
    fk_Cliente_fk_Usuario_id_Usuario AS [ID Cliente],
    fk_Tecnico_fk_Usuario_id_Usuario AS [ID Técnico],
    fk_ADM_FK_Usuario_id_Usuario AS [ID Administrador]
FROM Chamado;

-- Consultas
SELECT * FROM vw_Clientes_Completos ORDER BY nome_Usuario ASC;

SELECT * FROM vw_Chamados_Visualizacao;
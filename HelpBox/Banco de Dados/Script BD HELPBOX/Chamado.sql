---CRIAÇÂO DA TABELA CHAMADO---
SELECT * FROM Chamado;
CREATE TABLE Chamado (
    id_Cham INT IDENTITY(1,1) PRIMARY KEY,
    
    status_Cham VARCHAR(20) NOT NULL,
    dataAbertura_Cham DATETIME NOT NULL, 
    dataFechamento_Cham DATETIME NULL,
    dataProblema DATETIME NOT NULL,
    
    prioridade_Cham CHAR(1) NOT NULL,
    categoria_Cham VARCHAR(50) NOT NULL,
    
    descricao_Cham VARCHAR(1000) NOT NULL,
    solucaoIA_Cham VARCHAR(1000) NULL,
    solucaoTec_Cham VARCHAR(1000) NULL,
    solucaoFinal_Cham VARCHAR(1000) NULL,
    
    tecResponsavel_Cham INT NULL,

	CONSTRAINT FK_Chamado_Tecnico FOREIGN KEY (tecResponsavel_Cham) ---Chave estrangeira para id_User de Usuario
        REFERENCES Tecnico(id_User),
    
    CONSTRAINT CK_Datas_Chamado CHECK ( --- Garante que a data do problema não seja depois da abertura do chamado
        dataProblema <= dataAbertura_Cham AND
        (
            dataFechamento_Cham IS NULL OR 
            dataAbertura_Cham <= dataFechamento_Cham
        )
    ),
    
    CONSTRAINT CK_Status_Chamado CHECK (  --- Garante que o usuario vai inserir apenas as 3 opções de status
        LOWER(status_Cham) IN ('aberto', 'em andamento', 'fechado')
    ),
    
    CONSTRAINT CK_Prioridade_Chamado CHECK ( ---- Garante que o usuario vai inserir apenas as opções de prioridades existentes 
        UPPER(prioridade_Cham) IN ('A', 'M', 'B')
    )
    
    
);


---TRIGGER PARA PADRONIZAR---

CREATE TRIGGER trg_NormalizaStatusChamado
ON Chamado
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Para UPDATE
    IF EXISTS (SELECT * FROM inserted i JOIN deleted d ON i.id_Cham = d.id_Cham)
    BEGIN
        UPDATE c
        SET
            status_Cham = UPPER(LEFT(i.status_Cham,1)) + LOWER(SUBSTRING(i.status_Cham,2,LEN(i.status_Cham))),
            dataAbertura_Cham = i.dataAbertura_Cham,
            dataFechamento_Cham = i.dataFechamento_Cham,
            dataProblema = i.dataProblema,
            prioridade_Cham = UPPER(i.prioridade_Cham),
            categoria_Cham = i.categoria_Cham,
            descricao_Cham = i.descricao_Cham,
            solucaoIA_Cham = i.solucaoIA_Cham,
            solucaoTec_Cham = i.solucaoTec_Cham,
            solucaoFinal_Cham = i.solucaoFinal_Cham,
            tecResponsavel_Cham = i.tecResponsavel_Cham
        FROM Chamado c
        JOIN inserted i ON c.id_Cham = i.id_Cham;
    END

    -- Para INSERT
    IF EXISTS (SELECT * FROM inserted i WHERE NOT EXISTS (SELECT 1 FROM Chamado c WHERE c.id_Cham = i.id_Cham))
    BEGIN
        INSERT INTO Chamado (
            status_Cham,
            dataAbertura_Cham,
            dataFechamento_Cham,
            dataProblema,
            prioridade_Cham,
            categoria_Cham,
            descricao_Cham,
            solucaoIA_Cham,
            solucaoTec_Cham,
            solucaoFinal_Cham,
            tecResponsavel_Cham
        )
        SELECT
            UPPER(LEFT(status_Cham,1)) + LOWER(SUBSTRING(status_Cham,2,LEN(status_Cham))) AS status_Cham,
            dataAbertura_Cham,
            dataFechamento_Cham,
            dataProblema,
            UPPER(prioridade_Cham) AS prioridade_Cham,
            categoria_Cham,
            descricao_Cham,
            solucaoIA_Cham,
            solucaoTec_Cham,
            solucaoFinal_Cham,
            tecResponsavel_Cham
        FROM inserted;
    END
END;

---INSERTS PARA POVOAR---


INSERT INTO Chamado (
    status_Cham, 
    dataAbertura_Cham,
    dataFechamento_Cham,
    dataProblema,
    prioridade_Cham,
    categoria_Cham,
    descricao_Cham,
    solucaoIA_Cham,
    solucaoTec_Cham,
    solucaoFinal_Cham,
    tecResponsavel_Cham
) VALUES
('aberto', '2024-05-10 10:00:00', NULL, '2024-05-09 11:15:00', 'A', 'hardware', 'Computador não liga', NULL, NULL, NULL, 1),

('em andamento', '2024-05-10 09:00:00', NULL, '2024-05-09 08:30:00', 'M', 'rede', 'Sem acesso à internet', 'Verificar roteador', NULL, NULL, 1),

('fechado', '2024-05-10 10:00:00', '2024-05-11 16:45:00', '2024-05-09 11:15:00', 'B', 'software', 'Erro ao abrir sistema', NULL, 'Atualizado software', 'Problema resolvido', 1),

('aberto', '2024-05-10 12:30:00', NULL, '2024-05-10 11:00:00', 'M', 'email', 'Usuário não consegue enviar e-mail', NULL, NULL, NULL, 1);
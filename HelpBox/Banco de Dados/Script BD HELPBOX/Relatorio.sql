SELECT * FROM Relatorio;
CREATE TABLE Relatorio (
    id_Relatorio INT IDENTITY(1,1) PRIMARY KEY,
    id_Cham INT NOT NULL,
    relatorio VARCHAR(MAX) NOT NULL,
    id_UsuarioCriador INT NOT NULL,
    dataCriacao DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Relatorio_Chamado FOREIGN KEY (id_Cham) ---Chave estrangeira para id_Chamado de Chamado
        REFERENCES Chamado(id_Cham) ON DELETE CASCADE,

    CONSTRAINT FK_Relatorio_Usuario FOREIGN KEY (id_UsuarioCriador) ---Chave estrangeira para id_User de Usuario
        REFERENCES Usuario(id_User)
);


---TRIGGER QUE GARANTE QUE APENAS ADMINISTRADORES PODEM GERAR RELATORIOS---
CREATE TRIGGER trg_ValidarRelatorioADM
ON Relatorio
INSTEAD OF INSERT
AS
BEGIN
    -- Verifica se há algum usuário inserido que NÃO seja administrador
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1
            FROM Administrador a
            WHERE a.id_User = i.id_UsuarioCriador
        )
    )
    BEGIN
        RAISERROR('Apenas administradores podem criar relatórios.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Todos os usuários são administradores, então insere normalmente
    INSERT INTO Relatorio (id_Cham, relatorio, id_UsuarioCriador, dataCriacao)
    SELECT id_Cham, relatorio, id_UsuarioCriador, dataCriacao
    FROM inserted;
END;


--povoar relatorio

INSERT INTO Relatorio (id_Cham, relatorio, id_UsuarioCriador)
VALUES (
    4, -- ID de um chamado existente
    'Chamado solucionado com troca de cabo de rede.',
    4  -- ID de um usuário que está na tabela Administrador
);
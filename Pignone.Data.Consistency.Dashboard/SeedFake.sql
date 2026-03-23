SET NOCOUNT ON;

delete from [WebHookNotification] 
delete from [Rule] 
delete from [Group] 

DBCC CHECKIDENT ('WebHookNotification', RESEED, 1);
DBCC CHECKIDENT ('Rule', RESEED, 1);
DBCC CHECKIDENT ('Group', RESEED, 1);
---------------------------------------
-- 1. INSERT GROUPS (50)
---------------------------------------
DECLARE @groupIndex INT = 1;

WHILE @groupIndex <= 50
BEGIN
    INSERT INTO [Group] (Name, Description, Color)
    VALUES (
        CONCAT('Grupo_', @groupIndex),
        CONCAT('Descrição do grupo ', @groupIndex, ' - ', NEWID()),
        CONCAT('#', RIGHT(CONVERT(VARCHAR(40), NEWID()), 6))
    );

    SET @groupIndex += 1;
END

---------------------------------------
-- 3. INSERT RULES (200)
---------------------------------------
DECLARE @totalRules INT = 200;
DECLARE @inactiveLimit INT = 10;
DECLARE @ruleIndex INT = 1;

-- pegar ranges existentes
DECLARE @maxGroupId INT = (SELECT MAX(Id) FROM [Group]);

WHILE @ruleIndex <= @totalRules
BEGIN
    DECLARE @groupId INT;
    DECLARE @isActive BIT;

    -- distribuição aleatória
    SET @groupId = 1 + ABS(CHECKSUM(NEWID())) % @maxGroupId;

    -- 10 primeiras inativas
    IF @ruleIndex <= @inactiveLimit
        SET @isActive = 0;
    ELSE
        SET @isActive = 1;

    INSERT INTO Dashboard.dbo.[Rule] (
        Name,
        Description,
        MarkdownContent,
        StoredProcedure,
        Active,
        GroupId,
        ConnectionKey
    )
    VALUES (
        CONCAT('Regra_Negocio_', @ruleIndex),
        CONCAT('Descrição da regra de negócio ', @ruleIndex, ' - ', NEWID()),

        -- Markdown fake variado
CONCAT(
            '# Regra ', 
            @ruleIndex , 
            CHAR(10),
            '
# 📌 Regra de Validação de Dados

---

## 🧩 Visão Geral

A validação de dados é um dos pilares fundamentais para garantir a **qualidade, consistência e confiabilidade** das informações em qualquer sistema.

Esta regra de validação foi criada com o objetivo de:

- Identificar registros inconsistentes
- Prevenir falhas em processos dependentes de dados
- Facilitar auditoria e correção de informações
- Garantir aderência às regras de negócio

📌 **Por que isso é importante?**

Dados inconsistentes podem causar problemas como:
- Falhas em integrações com outros sistemas
- Erros em relatórios gerenciais
- Problemas no envio de e-mails ou notificações
- Decisões baseadas em dados incorretos

💡 *Exemplo real:*
> Um cliente cadastrado sem e-mail válido não receberá comunicações importantes, impactando diretamente a operação.

---

## ⚙️ Arquitetura da Solução

A solução foi implementada utilizando uma **Stored Procedure (SQL Server)**, que centraliza toda a lógica de validação.

### 🧱 Componentes principais:

- **Procedure:** `sp_rules_fake`
- **Tabela temporária:** utilizada para simulação e processamento
- **Geração de dados:** criação de registros para teste
- **Motor de validação:** aplicação das regras
- **Saída padronizada:** retorno estruturado

---

## 🔍 Detalhamento da Implementação

### 📦 Procedure

```sql
sp_rules_fake
			'
        ),

        'sp_rules_fake',

        @isActive,
        @groupId,
        'BancoTeste'
    );

    SET @ruleIndex += 1;
END


---------------------------------------
-- 3. INSERT WebHooks (200)
---------------------------------------
DECLARE @webhookIndex INT = 1;
WHILE @webhookIndex <= 30
BEGIN
    INSERT INTO WebHookNotification (Name, Uri)
    VALUES (
        CONCAT('Webhook_', @webhookIndex),
        'https://dashboad.requestcatcher.com/'
    );

    SET @webhookIndex += 1;
END

---------------------------------------
-- CHECK FINAL
---------------------------------------
SELECT 
    (SELECT COUNT(*) FROM [Group]) AS TotalGroups,
    (SELECT COUNT(*) FROM Dashboard.dbo.[Rule]) AS TotalRules,
    (SELECT COUNT(*) FROM Dashboard.dbo.[Rule] WHERE Active = 0) AS InactiveRules,
	(SELECT COUNT(*) FROM WebHookNotification) AS TotalWebhooks;
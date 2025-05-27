-- tarefa 7 --

-- Eu quero realizar um levantamento dos produtos que mais obtiveram o pior desemepenho nas devoluções, assim como calcular o faturamento líquido.  
-- Muitos dos produtos estão cadastrados sem cor, logo irei utilizar o comando COALESCE para retornar os valores NULL como 'Sem cores' 
-- Em seguida, vou tratar os dados, como a formtação dos números 


select *
from Purchasing.PurchaseOrderDetail


select *
from Production.Product


SELECT 
    p.Name AS Nome,
    p.ProductNumber AS Identificação,
    COALESCE(p.Color, 'Sem cor') AS Cor,
    SUM(u.RejectedQty) AS Devoluções,
    SUM(u.ReceivedQty) AS Recebido,
    SUM(u.LineTotal) AS Faturamento,
    SUM(u.StockedQty) AS Estoque
FROM Production.Product p
INNER JOIN Purchasing.PurchaseOrderDetail u ON p.ProductID = u.ProductID
GROUP BY p.Name, p.ProductNumber, p.Color
HAVING SUM(u.RejectedQty) > 0
ORDER BY SUM(u.ReceivedQty) DESC;

--- Correção 1 ---

-- NO = Formatação para número inteiros
-- C2 = Formatação para números monetários
-- Calculo para faturamento líquido (O que eu realmente faturei) = FORMAT(SUM(u.Linetotal) - SUM(u.RejectedQty * u.UnitPrice), 'C2') as Faturamento_L�quido

SELECT 
    p.Name AS Nome,
    p.ProductNumber AS Identificaçãoo,
    COALESCE(p.Color, 'Sem cor') AS Cor,
    FORMAT(SUM(u.RejectedQty), 'N0') AS Devoluções,
    FORMAT(SUM(u.ReceivedQty), 'N0') AS Recebido,
    FORMAT(SUM(u.LineTotal), 'C2') AS Faturamento,
    FORMAT(SUM(u.StockedQty), 'N0') AS Estoque,
    FORMAT(SUM(u.LineTotal) - SUM(u.RejectedQty * u.UnitPrice), 'C2') AS Faturamento_Liquido,
    FORMAT(SUM(u.RejectedQty * u.unitprice), 'C2') as Prejuizo_Financeiro
FROM Production.Product p
INNER JOIN Purchasing.PurchaseOrderDetail u ON p.ProductID = u.ProductID
GROUP BY p.Name, p.ProductNumber, p.Color
HAVING SUM(u.RejectedQty) > 0
ORDER BY SUM(u.ReceivedQty * u.UnitPrice) DESC


-- Para sabermos se um produto teve um real impacto no faturamento, utilizaremos uma porcentagem de 20% sobre o valor, logo, podemos definir como ALTO, MÉDIO ou ELSE = para condição BAIXA)


SELECT 
    p.Name AS Nome,
    p.ProductNumber AS Identificação,
    COALESCE(p.Color, 'Sem cor') AS Cor,
    FORMAT(SUM(u.RejectedQty), 'N0') AS Devoluções,
    FORMAT(SUM(u.ReceivedQty), 'N0') AS Recebido,
    FORMAT(SUM(u.LineTotal), 'C2') AS Faturamento,
    FORMAT(SUM(u.StockedQty), 'N0') AS Estoque,
    FORMAT(SUM(u.LineTotal) - SUM(u.RejectedQty * u.UnitPrice), 'C2') AS Faturamento_Liquido,
    FORMAT(SUM(u.RejectedQty * u.unitprice), 'C2') as Prejuizo_Financeiro,
    CASE
    WHEN SUM(u.RejectedQty * u.unitprice) > (SUM(u.Linetotal) * 0.2) THEN 'Alto'
    WHEN SUM(u.RejectedQty * u.unitprice) BETWEEN (SUM(u.Linetotal) * 0.1) AND (SUM(u.Linetotal) * 0.2) THEN 'Médio'
    ELSE 'Baixo'
    END as Prejuizo
FROM Production.Product p
INNER JOIN Purchasing.PurchaseOrderDetail u ON p.ProductID = u.ProductID
GROUP BY p.Name, p.ProductNumber, p.Color
HAVING SUM(u.RejectedQty) > 0
ORDER BY SUM(u.ReceivedQty * u.UnitPrice) DESC


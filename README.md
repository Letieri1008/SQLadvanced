# SQLadvanced

Tarefa complexa envolvendo códigos e formatação em SQL

---

# 📊 Análise de Prejuízo Financeiro no SQL

## 🔍 Objetivo

Esta análise busca identificar **os produtos com maior impacto negativo devido às devoluções**, além de calcular **o faturamento líquido**. Para isso:
- Utilizamos **COALESCE** para substituir valores NULL na coluna de cor.
- Aplicamos **formatação numérica** (`FORMAT()`).
- Calculamos **prejuízo absoluto e categorizado** (Alto, Médio e Baixo).

## 🛠️ Tabelas Utilizadas

```sql
SELECT * FROM Purchasing.PurchaseOrderDetail;
SELECT * FROM Production.Product;
```

## 📌 Primeira Consulta: Levantamento Inicial
Esta consulta identifica os produtos com **devoluções significativas**, ordenados por recebimentos.

```sql
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
```

## ✅ **Correção 1: Tratamento de Dados**
Nesta versão, aplicamos **formatações numéricas** para melhorar a legibilidade e calculamos **o faturamento líquido** (faturamento real após devoluções).

```sql
SELECT 
    p.Name AS Nome,
    p.ProductNumber AS Identificação,
    COALESCE(p.Color, 'Sem cor') AS Cor,
    FORMAT(SUM(u.RejectedQty), 'N0') AS Devoluções,
    FORMAT(SUM(u.ReceivedQty), 'N0') AS Recebido,
    FORMAT(SUM(u.LineTotal), 'C2') AS Faturamento,
    FORMAT(SUM(u.StockedQty), 'N0') AS Estoque,
    FORMAT(SUM(u.LineTotal) - SUM(u.RejectedQty * u.UnitPrice), 'C2') AS Faturamento_Liquido,
    FORMAT(SUM(u.RejectedQty * u.UnitPrice), 'C2') AS Prejuizo_Financeiro
FROM Production.Product p
INNER JOIN Purchasing.PurchaseOrderDetail u ON p.ProductID = u.ProductID
GROUP BY p.Name, p.ProductNumber, p.Color
HAVING SUM(u.RejectedQty) > 0
ORDER BY SUM(u.ReceivedQty * u.UnitPrice) DESC;
```

## 🔎 **Correção 2: Classificação do Prejuízo**
Nesta versão, categorizamos o impacto financeiro em **Alto, Médio e Baixo**, utilizando **percentuais sobre o faturamento total**.

```sql
SELECT 
    p.Name AS Nome,
    p.ProductNumber AS Identificação,
    COALESCE(p.Color, 'Sem cor') AS Cor,
    FORMAT(SUM(u.RejectedQty), 'N0') AS Devoluções,
    FORMAT(SUM(u.ReceivedQty), 'N0') AS Recebido,
    FORMAT(SUM(u.LineTotal), 'C2') AS Faturamento,
    FORMAT(SUM(u.StockedQty), 'N0') AS Estoque,
    FORMAT(SUM(u.LineTotal) - SUM(u.RejectedQty * u.UnitPrice), 'C2') AS Faturamento_Liquido,
    FORMAT(SUM(u.RejectedQty * u.UnitPrice), 'C2') AS Prejuizo_Financeiro,
    CASE
        WHEN SUM(u.RejectedQty * u.UnitPrice) > (SUM(u.LineTotal) * 0.2) THEN 'Alto'
        WHEN SUM(u.RejectedQty * u.UnitPrice) BETWEEN (SUM(u.LineTotal) * 0.1) AND (SUM(u.LineTotal) * 0.2) THEN 'Médio'
        ELSE 'Baixo'
    END AS Prejuizo
FROM Production.Product p
INNER JOIN Purchasing.PurchaseOrderDetail u ON p.ProductID = u.ProductID
GROUP BY p.Name, p.ProductNumber, p.Color
HAVING SUM(u.RejectedQty) > 0
ORDER BY SUM(u.ReceivedQty * u.UnitPrice) DESC;
```

## 🎯 **Conclusão**

Com estas análises, conseguimos:

- Identificar **os produtos mais problemáticos** em devoluções.
- Melhorar a **visualização dos dados com formatações adequadas**.
- Classificar **o impacto financeiro**, facilitando a tomada de decisões.

### **Resultado Final**
-Caso você tenha conseguido chegar a esse resultado, você pode conferir a seguir:




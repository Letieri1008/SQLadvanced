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
- Caso você tenha conseguido chegar a esse resultado, você pode conferir a seguir:


[Resolução tarefa 7.pdf](https://github.com/user-attachments/files/20447671/Resolucao.tarefa.7.pdf)

## Atualização SQL/ Avançado

### 🔎 Estrutura do cálculo
O prejuízo financeiro é calculado com esta expressão dentro da query:

```sql
SUM(u.RejectedQty * u.UnitPrice) AS Prejuizo_Financeiro
```

#### **Como funciona?**
1. `RejectedQty`: quantidade de produtos rejeitados/devolvidos.
2. `UnitPrice`: preço unitário do produto.
3. Multiplicamos `RejectedQty * UnitPrice` para obter o **valor total perdido** por cada produto.
4. `SUM(...)` é usado para somar os prejuízos ao longo de todas as compras, agregando os valores por produto.

### 📊 Classificação do prejuízo
Para categorizar o impacto financeiro, utilizamos a cláusula `CASE`:

```sql
CASE
    WHEN SUM(u.RejectedQty * u.UnitPrice) > (SUM(u.LineTotal) * 0.1) THEN 'Alto'
    WHEN SUM(u.RejectedQty * u.UnitPrice) BETWEEN (SUM(u.LineTotal) * 0.05) AND (SUM(u.LineTotal) * 0.2) THEN 'Médio'
    ELSE 'Baixo'
END AS Prejuizo
```

#### **Como essa lógica se aplica?**
- Se o prejuízo **supera 10% do faturamento total** (`LineTotal`), ele é categorizado como **Alto**.
- Se estiver entre **5% e 2% do faturamento**, é considerado **Médio**.
- Caso contrário, o prejuízo é **Baixo**.

### 📦 Lógica do remanejamento
O objetivo da análise é identificar produtos que precisam ser **remanejados**. Para isso, temos:

```sql
CASE
    WHEN SUM(u.RejectedQty * u.UnitPrice) > 50000 THEN 'Remanejo'
    ELSE ' - '
END AS Remanejamento
```

💡 **Se um produto acumulou mais de R$ 50.000 em prejuízos, ele é marcado para avaliação e possível remanejamento de estoque**.

---
### Código de consulta Atualizada 
```
SELECT 
    p.Name AS Nome,
    p.ProductNumber AS Identificação,
    ps.Name as Subcategoria,
    COALESCE(p.Color, 'Sem cor') AS Cor,
    FORMAT(SUM(u.RejectedQty), 'N0') AS Devoluções,
    FORMAT(SUM(u.ReceivedQty), 'N0') AS Recebido,
    FORMAT(SUM(u.LineTotal), 'C2') AS Faturamento,
    FORMAT(SUM(u.StockedQty), 'N0') AS Estoque,
    FORMAT(SUM(p.SafetyStockLevel), 'N0') SafeEstoque,
    FORMAT(SUM(u.LineTotal) - SUM(u.RejectedQty * u.UnitPrice), 'C2') AS Faturamento_Liquido,
    FORMAT(SUM(u.RejectedQty * u.UnitPrice), 'C2') AS Prejuizo_Financeiro,
    CASE
        WHEN SUM(u.RejectedQty * u.UnitPrice) > (SUM(u.LineTotal) * 0.1) THEN 'Alto'
        WHEN SUM(u.RejectedQty * u.UnitPrice) BETWEEN (SUM(u.LineTotal) * 0.05) AND (SUM(u.LineTotal) * 0.2) THEN 'Médio'
        ELSE 'Baixo'
    END AS Prejuizo,
    CASE
        WHEN SUM(u.RejectedQty * u.Unitprice) > 50000 THEN 'Remanejo'
        ELSE ' - '
        END as Remanejamento
FROM Production.Product p
INNER JOIN Purchasing.PurchaseOrderDetail u ON p.ProductID = u.ProductID
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY p.Name, p.ProductNumber, p.Color,  ps.Name
HAVING SUM(u.RejectedQty) > 0
ORDER BY SUM(u.ReceivedQty * u.UnitPrice) DESC;

```






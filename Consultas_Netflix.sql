select * from dbo.Netflix

-- Renomeei algumas colunas para facilitar as pesquisas
EXEC sp_rename 'dbo.Netflix.[Data_de_Estreia]', 'Data_estreia', 'COLUMN';


-- Volume total de conteúdos divididos por Tipo (Filme vs. Série)

SELECT Series_filmes,
	count(*) as Total_titulos
FROM dbo.Netflix
GROUP BY Series_filmes

-- Top 10 produções com maior Nota no IMDb

SELECT TOP 10 
	titulo,
	Series_filmes,
	Nota_IMDb
	FROM 
	dbo.Netflix
WHERE Nota_IMDb IS NOT NULL
ORDER BY 
	Nota_IMDb DESC

-- Média geral de avaliação e total de bilheteria dos filmes

SELECT 
    ROUND(AVG(Nota_IMDb), 2) AS Media_Geral_IMDb,
    SUM(Bilheteria) AS Bilheteria_Total_USD,
    ROUND(AVG(Bilheteria), 2) AS Bilheteria_Media_USD
FROM dbo.Netflix
WHERE Series_filmes = 'Movie';

-- 10 datas com mais lançamentos na netflix

select * from dbo.Netflix

SELECT top 10
    count(*) as contagem,
    datae_estreia_netflix
FROM
    dbo.Netflix
WHERE 
    datae_estreia_netflix IS NOT NULL
group by
    datae_estreia_netflix
order by
    count(*) desc

-- Quais os titulos com as maiores notas lançados na netflix em 14-04-2015?

SELECT
    titulo,
    Series_filmes,
    Nota_IMDb
FROM
    dbo.Netflix
WHERE
    datae_estreia_netflix = '2015-04-14'
order by
    Nota_IMDb desc, 
    titulo,
    Series_filmes

-- Por que existem notas 0 e quantas são?
-- há 2099 notas 0, poder ser algum erro ao pegar as informações ou não foram adicionadas

SELECT
    count(Nota_IMDb) as [contagem_nota_O]
FROM
    dbo.Netflix
where 
    Nota_IMDb = 0

-- Há quantas notas 0 em 2015-04-14
-- há 23 notas 0 nessa data

SELECT 
    count(Nota_IMDb) AS Qtde_notas_0
FROM dbo.Netflix
WHERE 
Nota_IMDb = 0 
    and datae_estreia_netflix = '2015-04-14';
 
-- Quais foram as menores notas e quantas foram de cada nota?
-- as 5 menores notas foram: nota 10 - 1, nota 14 - 3, nota 15 - 1, nota 16 - 2, nota 17 - 3

SELECT 
    Nota_IMDb,
    COUNT(Nota_IMDb) as [Qtde notas]
FROM
    dbo.Netflix
WHERE Nota_IMDb IS NOT NULL
group by
    Nota_IMDb
order by
    Nota_IMDb,
    COUNT(Nota_IMDb)
    

-- Primeira e última data de lançamento da netflix
-- menor data: 2015-04-14, maior data: 2021-03-04

select 
    min(datae_estreia_netflix) as 'menor data',
    max(datae_estreia_netflix) as 'maior data'
from
    dbo.Netflix
    
--A data de 14/04/2015 representa um pico artificial no dataset decorrente de uma carga inicial 
--em lote de títulos legados do catálogo, e não de lançamentos reais ocorridos em um único dia.


-- Contagem de Títulos e média de nota por Gênero 

SELECT 
    TRIM(value) AS Genero,
    COUNT(*) AS Total_Titulos,
    ROUND(AVG(Nota_IMDb), 2) AS Media_Nota
FROM dbo.Netflix
CROSS APPLY STRING_SPLIT(genero, ',')
WHERE genero IS NOT NULL
GROUP BY TRIM(value)
HAVING COUNT(*) >= 100
ORDER BY Total_Titulos DESC;

select * from dbo.Netflix

-- Contagem de Títulos e média de nota por categoria
SELECT
    TRIM(value) as Categoria,
    count(*) as Total_Titulos,
    ROUND(AVG(Nota_IMDb),2) as [Média_notas]
FROM
dbo.Netflix
cross apply string_split(Categorias, ',')
Where CategoriaS IS NOT NULL
GROUP BY
    TRIM(value)
HAVING COUNT(*) >= 100
ORDER BY Total_Titulos DESC;

-- Os 5 títulos com as maiores notas e sua categoria
-- Onde temos "No Festival" em primeiro e "Im Sorry" em décimo lugar

SELECT TOP 10 
    titulo,
    Nota_IMDb,
    Categorias
FROM dbo.Netflix
WHERE Categorias IS NOT NULL 
  AND Nota_IMDb IS NOT NULL
ORDER BY Nota_IMDb DESC;


-- Contar quantos títulos existem por categoria individual
SELECT 
    TRIM(value) AS Categoria, 
    COUNT(*) AS Total_Titulos
FROM dbo.Netflix
CROSS APPLY STRING_SPLIT(Categorias, ',')
WHERE Categorias IS NOT NULL
GROUP BY TRIM(value)          
ORDER BY Total_Titulos DESC;

-- Quantas categorias ÚNICAS existem no total?
-- 984 categorias existentes
SELECT 
    COUNT(DISTINCT TRIM(value)) AS [Total_Categorias_Distintas]
FROM dbo.Netflix
CROSS APPLY STRING_SPLIT(Categorias, ',')
WHERE Categorias IS NOT NULL;


-- Países com maior liberação de títulos
-- Portugal ficou em primeiro lugar e o Brazil ficou em oitavo lugar

SELECT 
    TRIM(value) as 'Países Liberados',
    count(*) as 'Total',
    round(avg(Nota_IMDb), 2) 'Média Notas'
FROM
    dbo.Netflix
cross apply string_split(paises_reproducao_liberada, ',')
WHERE
    paises_reproducao_liberada is not null
GROUP BY
    trim(value)
HAVING COUNT(*) >= 100
ORDER BY
    Total asc

-- Quais os 15 titulos mais premiados?
-- Paradise é o lider de premiação com 300 premios conquistados

SELECT top 15
    titulo,
    CAST(Premios_conquistados / 10.0 AS INT) AS 'Premios Conquistados' -- correção na culuna 
FROM
    dbo.Netflix
WHERE 
    Premios_conquistados IS NOT NULL
order by
    Premios_conquistados desc


-- Estratégia de Formato: Satisfação e Retenção por Tipo
-- Há mais quantidade de filmes, porém a media indica o Series prendem mais o público

SELECT 
    Series_filmes AS Formato,
    COUNT(*) AS 'Total Titulos',
    ROUND(AVG(Nota_IMDb /10.0), 2) AS 'Media Nota IMDb',
    ROUND(SUM(CASE WHEN (Nota_IMDb/10.0) >= 7.5 THEN 1.0 ELSE 0 END) * 100.0 / COUNT(*),2) AS '% Alta Qualidade'
FROM dbo.Netflix
WHERE Nota_IMDb > 0 -- >0 para excluir as notas 0
GROUP BY Series_filmes;

-- Analise de Gemas Escondidas (Hidden Gems)
-- 

SELECT TOP 20
    titulo,
    Series_filmes AS Formato,
    CAST(Nota_IMDb / 10.0 AS DECIMAL(3,1)) AS Nota_IMDb, -- converte cada valor para valor de 0 a 10, 3 digitos e 1 antes da vírgula
    Votos_IMDb,
    Categorias
FROM dbo.Netflix
WHERE Nota_IMDb >= 80              -- Equivalente a Nota >= 8.0 (escala 0-100)
  AND Votos_IMDb IS NOT NULL 
  AND Votos_IMDb BETWEEN 100 AND 10000 -- Filtra titulos com poucos votos
ORDER BY 
    Nota_IMDb DESC, 
    Votos_IMDb ASC;

-- sem o cast:
SELECT TOP 20
    titulo,
    Series_filmes AS Formato,
    Nota_IMDb / 10 as 'Nota_IMDb',
    Votos_IMDb,
    Categorias
FROM dbo.Netflix
WHERE Nota_IMDb >= 80
  AND Votos_IMDb IS NOT NULL 
  AND Votos_IMDb BETWEEN 100 AND 10000
ORDER BY Nota_IMDb DESC, Votos_IMDb ASC;


-- Segmentação de Filmes por Faixa de Bilheteria

SELECT 
    CASE 
        WHEN Bilheteria >= 100000000 THEN 'Blockbuster (>= $100M)'
        WHEN Bilheteria >= 10000000 THEN 'Médio Porte ($10M - $99M)'
        WHEN Bilheteria IS NOT NULL THEN 'Independente / Pequeno (< $10M)'
        ELSE 'Sem Dados de Bilheteria'
    END AS Categoria_Bilheteria,
    COUNT(*) AS Total_Filmes,
    ROUND(AVG(Nota_IMDb), 2) AS Media_IMDb
FROM dbo.Netflix
WHERE Series_filmes = 'Movie'
GROUP BY 
    CASE 
        WHEN Bilheteria >= 100000000 THEN 'Blockbuster (>= $100M)'
        WHEN Bilheteria >= 10000000 THEN 'Médio Porte ($10M - $99M)'
        WHEN Bilheteria IS NOT NULL THEN 'Independente / Pequeno (< $10M)'
        ELSE 'Sem Dados de Bilheteria'
    END
ORDER BY Media_IMDb DESC;

-- Identificação de "Hidden Gems" e Percentual sobre o Total
-- Filmes tem 4263 Gemas escondidas contra 2062 de Séries
-- Pode ser porque a quantidade de filmes é maior? Talvez, 
-- olhando para o percentual de Gemas, Series mostra ter mais Gemas escontidas com 54%

WITH CTE_Hidden_Gems AS (
    SELECT 
        titulo,
        Series_filmes AS 'Formato',
        Nota_IMDb,
        Nota_Gema_Escondida,
        CASE WHEN Nota_IMDb >= 7.5 AND Nota_Gema_Escondida >= 70 THEN 1 ELSE 0 END AS 'Eh Hidden Gem'
    FROM dbo.Netflix
)
SELECT 
    Formato,
    COUNT(*) AS 'Total Titulos',
    SUM("Eh Hidden Gem") AS 'Qtd Hidden Gems',
    ROUND(SUM("Eh Hidden Gem") * 100.0 / COUNT(*), 2) AS 'Percentual Hidden Gems'
FROM CTE_Hidden_Gems
GROUP BY Formato;


-- 3.3 Análise de Desempenho por Idioma Estratégico (CTEs e Filtros Avançados)
WITH CTE_Idiomas AS (
    SELECT 
        titulo,
        TRIM(value) AS Idioma,
        Nota_IMDb,
        Premios_conquistados
    FROM dbo.Netflix
    CROSS APPLY STRING_SPLIT(Linguas, ',')
    WHERE Linguas IS NOT NULL
)
SELECT 
    Idioma,
    COUNT(*) AS Total_Obras,
    ROUND(AVG(Nota_IMDb), 2) AS Media_IMDb,
    ROUND(SUM(Premios_conquistados),0) AS Total_Premios
FROM CTE_Idiomas
GROUP BY Idioma
HAVING COUNT(*) >= 50
ORDER BY Media_IMDb DESC;

select * from Netflix
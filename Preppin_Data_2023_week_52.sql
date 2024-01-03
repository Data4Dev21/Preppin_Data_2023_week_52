/*
Split the themes, so each theme/technique has its own field
Reshape the data so all the themes are in 1 field
Group the themes together to account for inaccuracies
Don't worry about being too accurate here, the main things to focus on it grouping things like Join/Joins and Aggregate/Aggregation. The way we've chosen to do it leaves us with 73 values, but that did involve a lot of manual grouping.
Reshape the data so we can see how many challenges each Technique appears in, broken down by Level (as per the output)
Create a Total field across the levels for each Technique
Rank the challenges based on the Total field to find out which Techniques we should prioritise for challenge making
*/

SELECT *
    FROM TIL_DATASCHOOL.DS36.PD_2023_WK52_PREPPIN_THEMES
    --where themes is null;
;
WITH CTE AS
(
SELECT *
    FROM TIL_DATASCHOOL.DS36.PD_2023_WK52_PREPPIN_THEMES,
    LATERAL SPLIT_TO_TABLE(TIL_DATASCHOOL.DS36.PD_2023_WK52_PREPPIN_THEMES.themes, ',')
    --where value is null
    ORDER BY SEQ, INDEX
)
,CTE1 AS
(
SELECT --initcap(trim(value)) as technique
level
,case when initcap(trim(value)) like 'Aggr%' then 'Aggregation'
      when initcap(trim(value)) like 'String%' then 'String Calculations'
      when initcap(trim(value)) like 'Data__nterpre%' then 'Data Interpreter'
      when initcap(trim(value)) like 'Dat__Calc%' then 'Date Calculations'
      when initcap(trim(value)) like 'I___tat%' then 'IF Statement'
      when initcap(trim(value)) like 'Updat%' then 'Updating a Workflow'
      when initcap(trim(value)) like 'Rank%' then 'Rank'
      when initcap(trim(value)) like 'Right_Joi%' then 'Right Joins'
      when initcap(trim(value)) like 'Running_%' then 'Running Sum'
      when initcap(trim(value)) like 'Scaff%' then 'Scaffolding'
      when initcap(trim(value)) like 'Simple__oi%' then 'Simple Joins'
      when initcap(trim(value)) like 'Left_Jo%' then 'Left_Joins'
      when initcap(trim(value)) like 'Appen%' then 'Append'
      when initcap(trim(value)) like 'Date__onver%' then 'Date Conversion'
      when initcap(trim(value)) like 'Fill__own%' then 'Fill Down'
      when initcap(trim(value)) like 'Filte%' then 'Filtering'
      when initcap(trim(value)) like 'Group%' then 'Grouping'
      when initcap(trim(value)) like 'Logical%' then 'Logical Calculations'
      when initcap(trim(value)) like 'Lookup%' then 'Lookup'
      when initcap(trim(value)) like 'Merge%' then 'Merge Fields'
      when initcap(trim(value)) like 'Moving_Ca%' then 'Moving Calculation'
      when initcap(trim(value)) like 'Pivot_Co%' then 'Pivot Columns To Rows'
      when initcap(trim(value)) like 'Numeric%' then 'Numeric Calculations'
      when initcap(trim(value)) like 'Non__qual%' then 'Non-Equal Join Clause'
      when initcap(trim(value)) like 'Multiple___________' then 'Multiple Join Clause'
      when initcap(trim(value)) like '%Pivot%' then 'Multiple Pivot'
      when initcap(trim(value)) like 'Spli%' then 'Split'
      when initcap(trim(value)) like 'Paramete%' then 'Parameters'
      when initcap(trim(value)) like 'Join%' then 'Joins'
      when initcap(trim(value)) like 'Mut%' then 'Multiple Join Clause'
      when initcap(trim(value)) like '%_Clause_Joi%' then 'Multiple Join Clause'
      else initcap(trim(value))
      end as technique
     ,count(*) as counts 
    FROM CTE
    GROUP BY 1,2
)
,CTE2 AS
(SELECT 
       COALESCE(NULLIF(technique,''), 'Unknown') as technique --replacing empty string field required coalesce
      ,ifnull(Beginner,0) as Beginner --ifnull worked for numeric fields
      ,ifnull(Intermediate,0) as Intermediate
      ,ifnull(Advanced,0) as Advanced
      ,ifnull("3-in-1",0) as "3-in-1"
      --,(Beginner + Intermediate + Advanced + "3-in-1") as total
    FROM CTE1
    PIVOT( min(counts) FOR level IN ('Beginner', 'Intermediate', 'Advanced','3-in-1')) AS P
(      
technique
,Beginner
,Intermediate
,Advanced
,"3-in-1"
))
--, cte3 as
--(
SELECT *
      ,(Beginner + Intermediate + Advanced + "3-in-1") as total
      ,dense_rank() over(order by total asc ) as priority
      FROM CTE2
    order by total;
     

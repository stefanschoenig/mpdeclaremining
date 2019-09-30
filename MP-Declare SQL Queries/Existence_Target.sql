USE EventLog

SELECT 'Existence' AS [Constraint], TaskA, a.Param1,
			(CAST(Count (Distinct Instance) AS FLOAT)/CAST((SELECT COUNT(*)
											FROM(SELECT Instance
													FROM [Log]
													GROUP BY Instance)t2
											) AS FLOAT)) AS Support,	
				((CAST(Count (Distinct Instance) AS FLOAT)/CAST((SELECT COUNT(*)
											FROM(SELECT Instance
													FROM [Log]
													GROUP BY Instance)t2
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(*)
											   FROM(SELECT Instance
													FROM [Log]
													GROUP BY Instance)t2) AS FLOAT)/CAST((SELECT COUNT(*)
																						  FROM(SELECT Instance
																							   FROM [Log]
																							   GROUP BY Instance) t) AS FLOAT))) AS Confidence

	FROM [Log] a,   (SELECT a.Task AS TaskA
					FROM [Log] a
					GROUP BY a.Task) x
	WHERE a.Task = x.TaskA									
	GROUP BY x.TaskA, a.Param1
HAVING (CAST(Count (Distinct Instance) AS FLOAT)/CAST((SELECT COUNT(*)
											FROM(SELECT Instance
													FROM [Log]
													GROUP BY Instance)t2
											) AS FLOAT)) > 0.9 AND
		
		((CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
											FROM(SELECT Instance
													FROM [Log]
													GROUP BY Instance)t2
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(*)
											   FROM(SELECT Instance
													FROM [Log]
													GROUP BY Instance)t2) AS FLOAT)/CAST((SELECT COUNT(*)
																						  FROM(SELECT Instance
																							   FROM [Log]
																							   GROUP BY Instance) t) AS FLOAT))) > 0.5

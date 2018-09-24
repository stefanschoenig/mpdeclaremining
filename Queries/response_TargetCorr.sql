USE EventLog

SELECT 'response' AS [Constraint], TaskA, TaskB, b.Resource,
			(CAST(COUNT(a.ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log]
										    WHERE Task LIKE TaskA
											) AS FLOAT)) AS Support,	
				((CAST(COUNT(a.ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log]
										    WHERE Task LIKE TaskA
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(Instance)
											   FROM(SELECT Instance
													FROM [Log]
													WHERE Task LIKE TaskA
													GROUP BY Instance)t2) AS FLOAT)/CAST((SELECT COUNT(Instance)
																						  FROM(SELECT Instance
																							   FROM [Log]
																							   GROUP BY Instance) t) AS FLOAT))) AS Confidence

	FROM [Log]a, [Log] b, (SELECT a.Task AS TaskA, b.Task AS TaskB
					FROM [Log] a, [Log] b
					WHERE a.Task != b.Task
					GROUP BY a.Task, b.Task) x
	WHERE a.Task = x.TaskA AND b.Task = x.TaskB AND a.Resource = b.Resource AND
							  b.ID IN(SELECT TOP 1 ID
									  FROM [Log] b
									  WHERE b.Task = x.TaskB AND b.Instance = a.Instance AND b.[Time] > a.[Time]
									  ORDER BY [Time] ASC)												
	GROUP BY x.TaskA, x.TaskB, b.Resource
HAVING (CAST(COUNT(a.ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log]
										    WHERE Task LIKE TaskA 
											) AS FLOAT)) > 0.95 AND
		((CAST(COUNT(a.ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log]
										    WHERE Task LIKE TaskA 
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(Instance)
											   FROM(SELECT Instance
													FROM [Log]
													WHERE Task LIKE TaskA 
													GROUP BY Instance)t2) AS FLOAT) / CAST((SELECT COUNT(Instance)
																							  FROM(SELECT Instance
																								   FROM [Log]
																								   GROUP BY Instance) t) AS FLOAT))) > 0.05
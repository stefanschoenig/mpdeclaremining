USE EventLog

SELECT 'chain response' AS [Constraint], TaskA, TaskB,
			(CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log]
										    WHERE Task LIKE TaskA
											) AS FLOAT)) AS Support,	
				((CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
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

	FROM [Log]a,   (SELECT a.Task AS TaskA, b.Task AS TaskB
					FROM [Log] a, [Log] b
					WHERE a.Task != b.Task
					GROUP BY a.Task, b.Task) x
	WHERE a.Task = x.TaskA AND EXISTS(SELECT ID
									  FROM [Log] b
									  WHERE b.Task = x.TaskB AND b.Instance = a.Instance AND b.[Time] > a.[Time])
														
										  AND NOT EXISTS(SELECT *
													     FROM [Log] b, [Log] c
													     WHERE c.Instance = a.Instance AND b.Instance = a.Instance AND b.Task = x.TaskB AND c.[Time] > a.[Time] AND c.[Time] < b.[Time])
														
	GROUP BY x.TaskA, x.TaskB
HAVING (CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log]
										    WHERE Task LIKE TaskA
											) AS FLOAT)) > 0.7 AND
		
		((CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
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
																								   GROUP BY Instance) t) AS FLOAT))) > 0.3
USE EventLog

SELECT 'response' AS [Constraint], TaskA, TaskB, a.Amount,
			(CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log_Road]
										    WHERE Task LIKE TaskA AND Amount LIKE a.Amount
											) AS FLOAT)) AS Support,	
				((CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log_Road]
										    WHERE Task LIKE TaskA AND Amount LIKE a.Amount
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(Instance)
											   FROM(SELECT Instance
													FROM [Log_Road]
													WHERE Task LIKE TaskA AND Amount LIKE a.Amount
													GROUP BY Instance)t2) AS FLOAT)/CAST((SELECT COUNT(Instance)
																						  FROM(SELECT Instance
																							   FROM [Log_Road]
																							   GROUP BY Instance) t) AS FLOAT))) AS Confidence

	FROM [Log_Road]a,   (SELECT a.Task AS TaskA, b.Task AS TaskB
					FROM [Log_Road] a, [Log_Road] b
					WHERE a.Task != b.Task
					GROUP BY a.Task, b.Task) x
	WHERE a.Task = x.TaskA AND EXISTS(SELECT ID
									  FROM [Log_Road] b
									  WHERE b.Task = x.TaskB AND b.Instance = a.Instance AND b.[Time] > a.[Time])
														
	GROUP BY x.TaskA, x.TaskB, a.Amount
HAVING (CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log_Road]
										    WHERE Task LIKE TaskA AND Amount LIKE a.Amount
											) AS FLOAT)) > 0.8 AND
		((CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log_Road]
										    WHERE Task LIKE TaskA AND Amount LIKE a.Amount
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(Instance)
											   FROM(SELECT Instance
													FROM [Log_Road]
													WHERE Task LIKE TaskA AND Amount LIKE a.Amount
													GROUP BY Instance)t2) AS FLOAT) / CAST((SELECT COUNT(Instance)
																							  FROM(SELECT Instance
																								   FROM [Log_Road]
																								   GROUP BY Instance) t) AS FLOAT))) > 0.001
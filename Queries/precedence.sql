USE EventLog

SELECT 'precedence' AS [Constraint], TaskA, TaskB,
			(CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
											FROM [Log]
										    WHERE Task LIKE TaskB
											) AS FLOAT)) AS Support,	
				((CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
											FROM [Log]
										    WHERE Task LIKE TaskB
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(*)
											   FROM(SELECT Instance
													FROM [Log]
													WHERE Task LIKE TaskB
													GROUP BY Instance)t2) AS FLOAT)/CAST((SELECT COUNT(*)
																						  FROM(SELECT Instance
																							   FROM [Log]
																							   GROUP BY Instance) t) AS FLOAT))) AS Confidence

	FROM [Log]a,   (SELECT a.Task AS TaskA, b.Task AS TaskB
					FROM [Log] a, [Log] b
					WHERE a.Task != b.Task
					GROUP BY a.Task, b.Task) x
	WHERE a.Task = x.TaskB AND EXISTS(SELECT *
									  FROM [Log] b
									  WHERE b.Task = x.TaskA AND b.Instance = a.Instance AND b.[Time] < a.[Time])
														
	GROUP BY x.TaskA, x.TaskB
HAVING (CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
											FROM [Log]
										    WHERE Task LIKE TaskB
											) AS FLOAT)) > 0.7 AND
		
		((CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
											FROM [Log]
										    WHERE Task LIKE TaskB
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(*)
											   FROM(SELECT Instance
													FROM [Log]
													WHERE Task LIKE TaskB
													GROUP BY Instance)t2) AS FLOAT) / CAST((SELECT COUNT(*)
																							  FROM(SELECT Instance
																								   FROM [Log]
																								   GROUP BY Instance) t) AS FLOAT))) > 0.3
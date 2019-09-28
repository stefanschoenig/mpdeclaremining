USE EventLog

SELECT 'alternate precedence' AS [Constraint], TaskA, TaskB, a.Param1, b.Param2,
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
	WHERE a.Task = x.TaskB AND b.Task = x.TaskA AND a.Param1 = b.Param1 AND
							  b.ID IN(SELECT TOP 1 ID
														FROM [Log] b
														WHERE b.Task = x.TaskA AND b.Instance = a.Instance AND b.[Time] < a.[Time])
														
										  AND NOT EXISTS(SELECT *
													     FROM [Log] b, [Log] c
													     WHERE c.Instance = a.Instance AND c.Task = x.TaskB AND b.Instance = a.Instance AND b.Task = x.TaskA AND c.[Time] < a.[Time] AND c.[Time] > b.[Time])
														
	GROUP BY x.TaskA, x.TaskB, a.Param1, b.Param2
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
USE EventLog

SELECT 'Init' AS [Constraint], TaskA,
			(CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
										   FROM(SELECT Instance
										        FROM [Log]
												GROUP BY Instance) t) AS FLOAT)) AS Support,	
				((CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
											    FROM(SELECT Instance
													 FROM [Log]
													 GROUP BY Instance) t) AS FLOAT)) * 
										(CAST((SELECT COUNT(*)
											   FROM(SELECT Instance
													FROM [Log]
													WHERE Task LIKE TaskA
													GROUP BY Instance)t2) AS FLOAT)/CAST((SELECT COUNT(*)
																						  FROM(SELECT Instance
																							   FROM [Log]
																							   GROUP BY Instance) t) AS FLOAT))) AS Confidence

	FROM [Log]a,   (SELECT a.Task AS TaskA
					FROM [Log] a
					GROUP BY a.Task) x
	WHERE a.Task = x.TaskA AND a.[Time] < ALL (SELECT [Time]
											   FROM [Log] b
											   WHERE a.ID != b.ID AND b.Instance = a.Instance)
														
	GROUP BY x.TaskA
    HAVING 			(CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
										   FROM(SELECT Instance
										        FROM [Log]
												GROUP BY Instance) t) AS FLOAT)) > 0.5	AND
				((CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
											    FROM(SELECT Instance
													 FROM [Log]
													 GROUP BY Instance) t) AS FLOAT)) * 
										(CAST((SELECT COUNT(*)
											   FROM(SELECT Instance
													FROM [Log]
													WHERE Task LIKE TaskA
													GROUP BY Instance)t2) AS FLOAT)/CAST((SELECT COUNT(*)
																						  FROM(SELECT Instance
																							   FROM [Log]
																							   GROUP BY Instance) t) AS FLOAT))) > 0.2
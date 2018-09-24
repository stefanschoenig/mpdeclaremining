USE EventLog
-- Direct Allocation

SELECT 'DirectAllocation' AS [Constraint], TaskA, a.[Resource],
		(CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log]
										    WHERE Task = TaskA
											) AS FLOAT)) AS Support,	
				((CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log]
										    WHERE Task = TaskA
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(Instance)
											   FROM(SELECT Instance
													FROM [Log]
													WHERE Task = TaskA
													GROUP BY Instance)t2) AS FLOAT)/CAST((SELECT COUNT(Instance)
																						  FROM(SELECT Instance
																							   FROM [Log]
																							   GROUP BY Instance) t) AS FLOAT))) AS Confidence


FROM [Log] a, (SELECT a.Task AS TaskA
			   FROM [Log] a
			   GROUP BY a.Task) x
WHERE a.Task = x.TaskA
GROUP BY x.TaskA, a.[Resource]
HAVING (CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log]
										    WHERE Task = TaskA
											) AS FLOAT)) > 0.9 AND
		
		((CAST(COUNT(ID) AS FLOAT)/CAST((SELECT COUNT(ID)
											FROM [Log]
										    WHERE Task = TaskA
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(Instance)
											   FROM(SELECT Instance
													FROM [Log]
													WHERE Task = TaskA
													GROUP BY Instance)t2) AS FLOAT) / CAST((SELECT COUNT(Instance)
																							  FROM(SELECT Instance
																								   FROM [Log]
																								   GROUP BY Instance) t) AS FLOAT))) > 0.5
OPTION (MAXDOP 0);
USE EventLog
-- Role based Allocation

SELECT 'CapabilityBasedAllocation' AS [Constraint], TaskA, r1.[Group],
				(CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
													FROM [Log]
													WHERE Task LIKE TaskA
													) AS FLOAT)) AS Support,	
						((CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
													FROM [Log]
													WHERE Task LIKE TaskA
													) AS FLOAT)) * 
												(CAST((SELECT COUNT(*)
													   FROM(SELECT Instance
															FROM [Log]
															WHERE Task LIKE TaskA
															GROUP BY Instance)t2) AS FLOAT)/CAST((SELECT COUNT(*)
																								  FROM(SELECT Instance
																									   FROM [Log]
																									   GROUP BY Instance) t) AS FLOAT))) AS Confidence
																												
FROM [Log] a, Relation r1, (SELECT a.Task AS TaskA
						    FROM [Log] a
						    GROUP BY a.Task) x
WHERE a.Task = x.TaskA AND r1.RelationType LIKE 'capability' AND a.[Resource] = r1.[Resource]
GROUP BY x.TaskA, r1.[Group]
HAVING (CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
											FROM [Log]
										    WHERE Task LIKE TaskA
											) AS FLOAT)) > 0.7 AND
		
		((CAST(COUNT(*) AS FLOAT)/CAST((SELECT COUNT(*)
											FROM [Log]
										    WHERE Task LIKE TaskA
											) AS FLOAT)) * 
										(CAST((SELECT COUNT(*)
											   FROM(SELECT Instance
													FROM [Log]
													WHERE Task LIKE TaskA
													GROUP BY Instance)t2) AS FLOAT) / CAST((SELECT COUNT(*)
																							  FROM(SELECT Instance
																								   FROM [Log]
																								   GROUP BY Instance) t) AS FLOAT))) > 0.1
USE datapath;


-- Overall new merchants acquisition
SELECT COUNT(DISTINCT t1.merchant_id) AS n_successful_new_merchants
FROM this_year_trx AS t1
LEFT JOIN last_year_trx AS t2
ON t1.merchant_id = t2.merchant_id
WHERE 
	t2.merchant_id IS NULL
	AND trx_status = 'Successful';


-- Each city new merchants performance
SELECT
	SUBSTRING(t1.merchant_id, 2, 3) AS city,
    COUNT(DISTINCT t1.merchant_id) AS n_successful_new_merchants
FROM this_year_trx AS t1
LEFT JOIN last_year_trx AS t2
ON t1.merchant_id = t2.merchant_id
WHERE
	t2.merchant_id IS NULL
    AND t1.trx_status = 'Successful'
GROUP BY 1;


-- Each month new merchants performance
SELECT 
	'Jan' AS month,
    SUBSTRING(t1.merchant_id, 2, 3) AS city,
    COUNT(DISTINCT t1.merchant_id) AS n_successful_new_merchants
FROM this_year_trx AS t1
LEFT JOIN last_year_trx AS t2
ON t1.merchant_id = t2.merchant_id
WHERE 
	MONTH(t1.trx_date) = 1
	AND t2.merchant_id IS NULL
	AND trx_status = 'Successful'
GROUP BY 1, 2
UNION
SELECT
	'Feb' AS month,
    t3.city,
    COUNT(DISTINCT t3.merchant_id) AS n_successful_new_merchants
FROM
(
	SELECT
		SUBSTRING(merchant_id, 2, 3) AS city,
		merchant_id
	FROM this_year_trx
	WHERE
		MONTH(trx_date) = 2
		AND trx_status = 'Successful'
) AS t3
LEFT JOIN last_year_trx AS t4
ON t3.merchant_id = t4.merchant_id
LEFT JOIN
(
	SELECT 
		SUBSTRING(merchant_id, 2, 3) AS city,
		merchant_id
	FROM this_year_trx
	WHERE
		MONTH(trx_date) = 1
		AND trx_status = 'Successful'
) AS t5
ON t3.merchant_id = t5.merchant_id
WHERE 
	t4.merchant_id IS NULL
    AND t5.merchant_id IS NULL
GROUP BY 1, 2;


-- Each city stayed and churned merchants every month
WITH cte AS
(
	SELECT
		t3.month,
		t3.city,
        t3.n_merchants AS stayed_merchants,
        t4.n_merchants AS init_merchants,
		(t3.n_merchants/t4.n_merchants*100) AS stayed_merchants_percentage,
		(t4.n_merchants - t3.n_merchants) AS churned_merchants
	FROM
	(
		SELECT
			'Jan' AS month,
			SUBSTRING(t1.merchant_id, 2, 3) AS city,
			COUNT(DISTINCT t1.merchant_id) AS n_merchants
		FROM this_year_trx AS t1
		RIGHT JOIN last_year_trx AS t2
		ON t1.merchant_id = t2.merchant_id
		WHERE
			MONTH(t1.trx_date) = 1
			AND t1.trx_status = 'Successful'
			AND DATEDIFF(t1.trx_date, t2.last_trx_date) <= 30
		GROUP BY 1, 2
	) AS t3
	LEFT JOIN
	(
		SELECT
			SUBSTRING(t1.merchant_id, 2, 3) AS city,
			COUNT(DISTINCT t1.merchant_id) AS n_merchants
		FROM last_year_trx AS t1
		GROUP BY 1
	) AS t4
	ON t3.city = t4.city
    GROUP BY 1, 2
	UNION
	SELECT
		t3.month,
		t3.city,
        t3.n_merchants AS stayed_merchants,
        t4.n_merchants AS init_merchants,
		(t3.n_merchants/t4.n_merchants*100) AS stayed_merchants_percentage,
		(t4.n_merchants - t3.n_merchants) AS churned_merchants
	FROM
	(
		SELECT
			'Feb' AS month,
			SUBSTRING(t1.merchant_id, 2, 3) AS city,
			COUNT(DISTINCT t1.merchant_id) AS n_merchants
		FROM
		(
			SELECT
				merchant_id,
				trx_date
			FROM this_year_trx
			WHERE
				MONTH(trx_date) = 2
				AND trx_status = 'Successful'
		) AS t1
		RIGHT JOIN
		(
			SELECT
				merchant_id,
				trx_date
			FROM this_year_trx
			WHERE
				MONTH(trx_date) = 1
				AND trx_status = 'Successful'
		) AS t2
		ON t1.merchant_id = t2.merchant_id
		WHERE DATEDIFF(t1.trx_date, t2.trx_date) <= 30
		GROUP BY 1, 2
	) AS t3
	LEFT JOIN
	(
		SELECT
			SUBSTRING(merchant_id, 2, 3) AS city,
			COUNT(DISTINCT merchant_id) AS n_merchants
		FROM this_year_trx
		WHERE
			MONTH(trx_date) = 1
			AND trx_status = 'Successful'
		GROUP BY 1
	) AS t4
	ON t3.city = t4.city
    GROUP BY 1, 2
)
SELECT * FROM cte;


-- Overall stayed and churned merchants every month
WITH cte AS
(
	SELECT
		t3.month,
		t3.city,
        t3.n_merchants AS stayed_merchants,
        t4.n_merchants AS init_merchants,
		(t3.n_merchants/t4.n_merchants*100) AS stayed_merchants_percentage,
		(t4.n_merchants - t3.n_merchants) AS churned_merchants
	FROM
	(
		SELECT
			'Jan' AS month,
			SUBSTRING(t1.merchant_id, 2, 3) AS city,
			COUNT(DISTINCT t1.merchant_id) AS n_merchants
		FROM this_year_trx AS t1
		RIGHT JOIN last_year_trx AS t2
		ON t1.merchant_id = t2.merchant_id
		WHERE
			MONTH(t1.trx_date) = 1
			AND t1.trx_status = 'Successful'
			AND DATEDIFF(t1.trx_date, t2.last_trx_date) <= 30
		GROUP BY 1, 2
	) AS t3
	LEFT JOIN
	(
		SELECT
			SUBSTRING(t1.merchant_id, 2, 3) AS city,
			COUNT(DISTINCT t1.merchant_id) AS n_merchants
		FROM last_year_trx AS t1
		GROUP BY 1
	) AS t4
	ON t3.city = t4.city
    GROUP BY 1, 2
	UNION
	SELECT
		t3.month,
		t3.city,
        t3.n_merchants AS stayed_merchants,
        t4.n_merchants AS init_merchants,
		(t3.n_merchants/t4.n_merchants*100) AS stayed_merchants_percentage,
		(t4.n_merchants - t3.n_merchants) AS churned_merchants
	FROM
	(
		SELECT
			'Feb' AS month,
			SUBSTRING(t1.merchant_id, 2, 3) AS city,
			COUNT(DISTINCT t1.merchant_id) AS n_merchants
		FROM
		(
			SELECT
				merchant_id,
				trx_date
			FROM this_year_trx
			WHERE
				MONTH(trx_date) = 2
				AND trx_status = 'Successful'
		) AS t1
		RIGHT JOIN
		(
			SELECT
				merchant_id,
				trx_date
			FROM this_year_trx
			WHERE
				MONTH(trx_date) = 1
				AND trx_status = 'Successful'
		) AS t2
		ON t1.merchant_id = t2.merchant_id
		WHERE DATEDIFF(t1.trx_date, t2.trx_date) <= 30
		GROUP BY 1, 2
	) AS t3
	LEFT JOIN
	(
		SELECT
			SUBSTRING(merchant_id, 2, 3) AS city,
			COUNT(DISTINCT merchant_id) AS n_merchants
		FROM this_year_trx
		WHERE
			MONTH(trx_date) = 1
			AND trx_status = 'Successful'
		GROUP BY 1
	) AS t4
	ON t3.city = t4.city
    GROUP BY 1, 2
)
SELECT
	month,
    AVG(stayed_merchants_percentage) AS avg_stayed_merchants_percentage,
    SUM(churned_merchants) AS total_churned_merchants
FROM cte
GROUP BY 1;


-- Monthly merchants' promo participation rate in each city
WITH cte AS
(
	SELECT
		t3.month,
		t3.city,
		(t3.n_merchants/t4.n_merchants) AS promo_participated_merchants_rate
	FROM
	(
		SELECT
			'Jan' AS month,
			SUBSTRING(merchant_id, 2, 3) AS city,
			COUNT(DISTINCT merchant_id) AS n_merchants
		FROM this_year_trx
		WHERE 
			MONTH(trx_date) = 1
			AND trx_status = 'Successful'
			AND total_revenue_after_discount < total_revenue
		GROUP BY 1, 2
	) AS t3
	JOIN
	(
		SELECT
			SUBSTRING(merchant_id, 2, 3) AS city,
			COUNT(DISTINCT merchant_id) AS n_merchants
		FROM this_year_trx
		WHERE MONTH(trx_date) = 1
		GROUP BY 1
	) AS t4
	ON t3.city = t4.city
	UNION
	SELECT
		t3.month,
		t3.city,
		(t3.n_merchants/t4.n_merchants) AS promo_participated_merchants_rate
	FROM
	(
		SELECT
			'Feb' AS month,
			SUBSTRING(merchant_id, 2, 3) AS city,
			COUNT(DISTINCT merchant_id) AS n_merchants
		FROM this_year_trx
		WHERE 
			MONTH(trx_date) = 2
			AND trx_status = 'Successful'
			AND total_revenue_after_discount < total_revenue
		GROUP BY 1, 2
	) AS t3
	JOIN
	(
		SELECT
			SUBSTRING(merchant_id, 2, 3) AS city,
			COUNT(DISTINCT merchant_id) AS n_merchants
		FROM this_year_trx
		WHERE MONTH(trx_date) = 2
		GROUP BY 1
	) AS t4
	ON t3.city = t4.city
)
SELECT *
FROM cte;


-- Overall (monthly average from each city) merchants' promo participation rate
WITH cte AS
(
	SELECT
		t3.month,
		t3.city,
		(t3.n_merchants/t4.n_merchants) AS promo_participated_merchants_rate
	FROM
	(
		SELECT
			'Jan' AS month,
			SUBSTRING(merchant_id, 2, 3) AS city,
			COUNT(DISTINCT merchant_id) AS n_merchants
		FROM this_year_trx
		WHERE 
			MONTH(trx_date) = 1
			AND trx_status = 'Successful'
			AND total_revenue_after_discount < total_revenue
		GROUP BY 1, 2
	) AS t3
	JOIN
	(
		SELECT
			SUBSTRING(merchant_id, 2, 3) AS city,
			COUNT(DISTINCT merchant_id) AS n_merchants
		FROM this_year_trx
		WHERE MONTH(trx_date) = 1
		GROUP BY 1
	) AS t4
	ON t3.city = t4.city
	UNION
	SELECT
		t3.month,
		t3.city,
		(t3.n_merchants/t4.n_merchants) AS promo_participated_merchants_rate
	FROM
	(
		SELECT
			'Feb' AS month,
			SUBSTRING(merchant_id, 2, 3) AS city,
			COUNT(DISTINCT merchant_id) AS n_merchants
		FROM this_year_trx
		WHERE 
			MONTH(trx_date) = 2
			AND trx_status = 'Successful'
			AND total_revenue_after_discount < total_revenue
		GROUP BY 1, 2
	) AS t3
	JOIN
	(
		SELECT
			SUBSTRING(merchant_id, 2, 3) AS city,
			COUNT(DISTINCT merchant_id) AS n_merchants
		FROM this_year_trx
		WHERE MONTH(trx_date) = 2
		GROUP BY 1
	) AS t4
	ON t3.city = t4.city
)
SELECT
	month,
    ROUND(AVG(promo_participated_merchants_rate), 4) AS avg_promo_participated_merchants_rate
FROM cte
GROUP BY 1;

-- Getting the number of ads at each price point to bettter understand the distribution

SELECT 
    CASE
        WHEN price BETWEEN 0 AND 4999 THEN '0-5000'
        WHEN price BETWEEN 5000 AND 9999 THEN '5000-10000'
        WHEN price BETWEEN 10000 AND 14999 THEN '10000-15000'
        WHEN price BETWEEN 15000 AND 19999 THEN '15000-20000'
        WHEN price BETWEEN 20000 AND 24999 THEN '20000-25000'
        WHEN price BETWEEN 25000 AND 29999 THEN '25000-30000'
        WHEN price BETWEEN 30000 AND 50000 THEN '30000-50000'
        ELSE '50000+'
    END AS price_range,
    COUNT(price) AS count,
    ROUND(COUNT(price) / (SELECT 
                    COUNT(*)
                FROM
                    ad_data) * 100,
            2) AS total_percentage
FROM
    ad_data
GROUP BY price_range
ORDER BY CASE
    WHEN price BETWEEN 0 AND 4999 THEN 1
    WHEN price BETWEEN 5000 AND 9999 THEN 2
    WHEN price BETWEEN 10000 AND 14999 THEN 3
    WHEN price BETWEEN 15000 AND 19999 THEN 4
    WHEN price BETWEEN 20000 AND 24999 THEN 5
    WHEN price BETWEEN 25000 AND 29999 THEN 6
    WHEN price BETWEEN 30000 AND 50000 THEN 7
    ELSE 8
END;

-- Question I)
-- Grouping price categories and extracting additional data

SELECT 
    CASE
        WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
        WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
        WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
        ELSE 'Luxury'
    END AS category,
    CASE
        WHEN price BETWEEN 0 AND 4999 THEN '0-5000'
        WHEN price BETWEEN 5000 AND 19999 THEN '5000-20000'
        WHEN price BETWEEN 20000 AND 49999 THEN '20000-50000'
        ELSE '50000+'
    END AS price_range,
    COUNT(price) AS number_of_ads,
    ROUND(COUNT(price) / (SELECT 
                    COUNT(*)
                FROM
                    ad_data) * 100,
            2) AS ads_total_percentage,
    SUM(views) AS views,
    ROUND(SUM(views) / (SELECT 
                    SUM(views)
                FROM
                    ad_data) * 100,
            2) AS views_percentage,
    ROUND(AVG(views)) AS views_per_ad,
    ROUND((SUM(views) / (SELECT 
                    SUM(views)
                FROM
                    ad_data)) / (COUNT(price) / (SELECT 
                    COUNT(*)
                FROM
                    ad_data)),
            2) AS interest_vs_availability
FROM
    ad_data
GROUP BY category
ORDER BY CASE
    WHEN price BETWEEN 0 AND 4999 THEN 1
    WHEN price BETWEEN 5000 AND 19999 THEN 2
    WHEN price BETWEEN 20000 AND 49999 THEN 3
    ELSE 5
END;


-- Exploring data at different pricepoint
-- Economy:


SELECT 
    brand.car_brand AS Brand,
    model.model AS Model,
    model.views AS Views
FROM
    (SELECT 
        a.car_brand, SUM(b.views) AS views, COUNT(a.id) AS count
    FROM
        car_info a
    JOIN ad_data b ON a.id = b.id
    WHERE
        b.price < 5000
    GROUP BY a.car_brand
    HAVING COUNT(a.id) > 1
    ORDER BY SUM(b.views) DESC) AS brand
        LEFT JOIN
    (SELECT 
        a.car_brand, a.model, SUM(b.views) AS views
    FROM
        car_info a
    JOIN ad_data b ON a.id = b.id
    WHERE
        b.price < 5000
    GROUP BY a.car_brand , a.model) AS model ON model.car_brand = brand.car_brand
ORDER BY brand.views DESC , model.views DESC
;

SELECT 
    a.body_type,
    SUM(b.views) AS views,
    COUNT(a.id) AS count,
    ROUND(AVG(b.views), 1) AS 'View per Ad'
FROM
    car_info a
        JOIN
    ad_data b ON a.id = b.id
WHERE
    b.price < 5000
GROUP BY a.body_type
HAVING COUNT(a.id) > 1
ORDER BY AVG(b.views) DESC;
    
-- Standard:


SELECT 
    brand.car_brand AS Brand,
    model.model AS Model,
    model.views AS Views
FROM
    (SELECT 
        a.car_brand, SUM(b.views) AS views, COUNT(a.id) AS count
    FROM
        car_info a
    JOIN ad_data b ON a.id = b.id
    WHERE
        b.price BETWEEN 5000 AND 19999
    GROUP BY a.car_brand
    HAVING COUNT(a.id) > 1
    ORDER BY SUM(b.views) DESC) AS brand
        LEFT JOIN
    (SELECT 
        a.car_brand, a.model, SUM(b.views) AS views
    FROM
        car_info a
    JOIN ad_data b ON a.id = b.id
    WHERE
        b.price BETWEEN 5000 AND 19999
    GROUP BY a.car_brand , a.model) AS model ON model.car_brand = brand.car_brand
ORDER BY brand.views DESC , model.views DESC
;

SELECT 
    a.body_type,
    SUM(b.views) AS views,
    COUNT(a.id) AS count,
    ROUND(AVG(b.views), 1) AS 'View per Ad'
FROM
    car_info a
        JOIN
    ad_data b ON a.id = b.id
WHERE
    b.price BETWEEN 5000 AND 19999
GROUP BY a.body_type
HAVING COUNT(a.id) > 1
ORDER BY AVG(b.views) DESC;
    
-- Premium:

SELECT 
    brand.car_brand AS Brand,
    model.model AS Model,
    model.views AS Views
FROM
    (SELECT 
        a.car_brand, SUM(b.views) AS views, COUNT(a.id) AS count
    FROM
        car_info a
    JOIN ad_data b ON a.id = b.id
    WHERE
        b.price BETWEEN 20000 AND 49999
    GROUP BY a.car_brand
    HAVING COUNT(a.id) > 1
    ORDER BY SUM(b.views) DESC) AS brand
        LEFT JOIN
    (SELECT 
        a.car_brand, a.model, SUM(b.views) AS views
    FROM
        car_info a
    JOIN ad_data b ON a.id = b.id
    WHERE
        b.price BETWEEN 20000 AND 49999
    GROUP BY a.car_brand , a.model) AS model ON model.car_brand = brand.car_brand
ORDER BY brand.views DESC , model.views DESC
;

SELECT 
    a.body_type,
    SUM(b.views) AS views,
    COUNT(a.id) AS count,
    ROUND(AVG(b.views), 1) AS 'View per Ad'
FROM
    car_info a
        JOIN
    ad_data b ON a.id = b.id
WHERE
    b.price BETWEEN 20000 AND 49999
GROUP BY a.body_type
HAVING COUNT(a.id) > 1
ORDER BY AVG(b.views) DESC;
    
-- Luxury:

SELECT 
    brand.car_brand AS Brand,
    model.model AS Model,
    model.views AS Views
FROM
    (SELECT 
        a.car_brand, SUM(b.views) AS views, COUNT(a.id) AS count
    FROM
        car_info a
    JOIN ad_data b ON a.id = b.id
    WHERE
        b.price > 49999
    GROUP BY a.car_brand
    HAVING COUNT(a.id) > 1
    ORDER BY SUM(b.views) DESC) AS brand
        LEFT JOIN
    (SELECT 
        a.car_brand, a.model, SUM(b.views) AS views
    FROM
        car_info a
    JOIN ad_data b ON a.id = b.id
    WHERE
        b.price > 49999
    GROUP BY a.car_brand , a.model) AS model ON model.car_brand = brand.car_brand
ORDER BY brand.views DESC , model.views DESC
;

SELECT 
    a.body_type,
    SUM(b.views) AS views,
    COUNT(a.id) AS count,
    ROUND(AVG(b.views), 1) AS 'View per Ad'
FROM
    car_info a
        JOIN
    ad_data b ON a.id = b.id
WHERE
    b.price > 49999
GROUP BY a.body_type
HAVING COUNT(a.id) > 1
ORDER BY AVG(b.views) DESC;
    
    
-- Question II)
-- Getting a table of sold ads

CREATE TABLE sold_ads AS SELECT c.*,
    b.description_length,
    b.image_number,
    b.advertiser,
    MAX(DATEDIFF(a.updated_date, b.posted_date)) - 1 AS 'Sold in _ Days',
    b.price,
    MAX(b.views) AS views FROM
    updates a
        JOIN
    ad_data b ON a.id = b.id
        JOIN
    car_info c ON b.id = c.id
WHERE
    published = 'N'
        AND DATEDIFF(a.updated_date, b.posted_date) < 30
GROUP BY url
ORDER BY DATEDIFF(a.updated_date, b.posted_date) DESC;

-- Unsuccessful ads
CREATE TABLE unsold_ads AS SELECT c.*,
    b.description_length,
    b.image_number,
    b.advertiser,
    MAX(DATEDIFF(a.updated_date, b.posted_date)) AS 'Unsold in _ Days',
    b.price,
    MAX(b.views) AS views FROM
    updates a
        JOIN
    ad_data b ON a.id = b.id
        JOIN
    car_info c ON b.id = c.id
WHERE
    published = 'Y'
        AND DATEDIFF(a.updated_date, b.posted_date) > 30
GROUP BY url
ORDER BY DATEDIFF(a.updated_date, b.posted_date) DESC;

SELECT 
    s.category,
    s.price_range,
    s.number_of_cars AS sold_cars,
    ROUND((s.number_of_cars / (SELECT 
                    COUNT(*)
                FROM
                    sold_ads)) * 100,
            2) AS percentage_sold_cars,
    a.number_of_ads AS total_ads,
    ROUND((s.number_of_cars / a.number_of_ads) * 100,
            2) AS percentage_success_rate,
    s.sold_views AS sold_views,
    a.views AS all_views,
    ROUND((s.sold_views / a.views) * 100, 2) AS sales_to_views_percentage,
    ROUND(s.sold_views / s.number_of_cars) AS views_per_sold_ad,
    ROUND(a.views / a.number_of_ads) AS views_per_total_ad,
    ROUND((((a.views / a.number_of_ads) - (s.sold_views / s.number_of_cars)) / (a.views / a.number_of_ads)) * 100,
            2) AS 'Percent Difference in AVG views'
FROM
    (SELECT 
        CASE
                WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
                WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
                WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
                ELSE 'Luxury'
            END AS category,
            CASE
                WHEN price BETWEEN 0 AND 4999 THEN '0-5000'
                WHEN price BETWEEN 5000 AND 19999 THEN '5000-20000'
                WHEN price BETWEEN 20000 AND 49999 THEN '20000-50000'
                ELSE '50000+'
            END AS price_range,
            COUNT(price) AS number_of_cars,
            ROUND(SUM(views)) AS sold_views
    FROM
        sold_ads
    GROUP BY category
    ORDER BY CASE
        WHEN price BETWEEN 0 AND 4999 THEN 1
        WHEN price BETWEEN 5000 AND 19999 THEN 2
        WHEN price BETWEEN 20000 AND 49999 THEN 3
        ELSE 5
    END) AS s
        JOIN
    (SELECT 
        CASE
                WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
                WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
                WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
                ELSE 'Luxury'
            END AS category,
            CASE
                WHEN price BETWEEN 0 AND 4999 THEN '0-5000'
                WHEN price BETWEEN 5000 AND 19999 THEN '5000-20000'
                WHEN price BETWEEN 20000 AND 49999 THEN '20000-50000'
                ELSE '50000+'
            END AS price_range,
            COUNT(price) AS number_of_ads,
            ROUND(COUNT(price) / (SELECT 
                    COUNT(*)
                FROM
                    ad_data) * 100, 2) AS ads_total_percentage,
            SUM(views) AS views,
            ROUND(SUM(views) / (SELECT 
                    SUM(views)
                FROM
                    ad_data) * 100, 2) AS views_percentage,
            ROUND(AVG(views)) AS views_per_ad,
            ROUND((SUM(views) / (SELECT 
                    SUM(views)
                FROM
                    ad_data)) / (COUNT(price) / (SELECT 
                    COUNT(*)
                FROM
                    ad_data)), 2) AS interest_vs_availability
    FROM
        ad_data
    GROUP BY category
    ORDER BY CASE
        WHEN price BETWEEN 0 AND 4999 THEN 1
        WHEN price BETWEEN 5000 AND 19999 THEN 2
        WHEN price BETWEEN 20000 AND 49999 THEN 3
        ELSE 5
    END) AS a ON a.category = s.category;
    
    
-- Question III):
-- Importance of Marketing

SELECT 
    CASE
        WHEN `Sold in _ Days` < 8 THEN '1 Week'
        WHEN `Sold in _ Days` BETWEEN 8 AND 13 THEN '2 Weeks'
        WHEN `Sold in _ Days` BETWEEN 14 AND 20 THEN '3 Weeks'
        WHEN `Sold in _ Days` > 20 THEN '4 Weeks'
    END AS sold_in,
    CONCAT(IF(ROUND(AVG(LENGTH(b.title)) - STDDEV_POP(LENGTH(b.title))) > 0,
                ROUND((AVG(LENGTH(b.title)) - STDDEV_POP(LENGTH(b.title)))),
                0),
            ' - ',
            ROUND((AVG(LENGTH(b.title)) + STDDEV_POP(LENGTH(b.title))),
                    0)) AS words_in_title,
    CONCAT(IF(ROUND(AVG(a.description_length) - STDDEV_POP(a.description_length)) > 0,
                ROUND(AVG(a.description_length) - STDDEV_POP(a.description_length)),
                0),
            ' - ',
            ROUND(AVG(a.description_length) + STDDEV_POP(a.description_length))) AS description_length_range,
    CONCAT(IF(ROUND(AVG(a.image_number) - STDDEV_POP(a.image_number)) > 0,
                ROUND(AVG(a.image_number) - STDDEV_POP(a.image_number)),
                0),
            ' - ',
            ROUND(AVG(a.image_number) + STDDEV_POP(a.image_number))) AS image_number_range
FROM
    sold_ads a
        JOIN
    ad_data b ON a.id = b.id
GROUP BY sold_in
ORDER BY sold_in;

-- Importance of PR

SELECT 
    a.advertiser,
    a.sold_ads,
    b.all_ads,
    ROUND(a.sold_ads / b.all_ads * 100, 2) AS success_rate
FROM
    (SELECT 
        advertiser, COUNT(advertiser) AS sold_ads
    FROM
        sold_ads
    GROUP BY advertiser) AS a
        LEFT JOIN
    (SELECT 
        advertiser, COUNT(advertiser) AS all_ads
    FROM
        ad_data
    GROUP BY advertiser) AS b ON a.advertiser = b.advertiser
GROUP BY a.advertiser
HAVING b.all_ads > 1
ORDER BY success_rate DESC , sold_ads DESC;

SELECT 
    CASE
        WHEN a.advertiser REGEXP 'auto|cars|motors|group|car|expo' THEN 'Businesses'
        ELSE 'Individuals'
    END AS adv,
    SUM(a.sold_ads) AS sold_ads,
    SUM(b.all_ads) AS posted_ads,
    ROUND(SUM(a.sold_ads) / SUM(b.all_ads) * 100,
            2) AS success_rate
FROM
    (SELECT 
        advertiser, COUNT(advertiser) AS sold_ads
    FROM
        sold_ads
    GROUP BY advertiser) AS a
        LEFT JOIN
    (SELECT 
        advertiser, COUNT(advertiser) AS all_ads
    FROM
        ad_data
    GROUP BY advertiser) AS b ON a.advertiser = b.advertiser
GROUP BY adv
ORDER BY success_rate DESC;

-- Pricing

SELECT 
    a.category,
    b.avg_price AS sold_avg_price,
    c.avg_price AS all_avg_price,
    ROUND(-(c.avg_price - b.avg_price) / c.avg_price * 100,
            2) AS percentage_price_difference
FROM
    (SELECT 
        CASE
                WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
                WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
                WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
                ELSE 'Luxury'
            END AS category
    FROM
        sold_ads
    GROUP BY category
    ORDER BY CASE
        WHEN price BETWEEN 0 AND 4999 THEN 1
        WHEN price BETWEEN 5000 AND 19999 THEN 2
        WHEN price BETWEEN 20000 AND 49999 THEN 3
        ELSE 5
    END) AS a
        JOIN
    (SELECT 
        CASE
                WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
                WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
                WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
                ELSE 'Luxury'
            END AS category,
            ROUND(AVG(price)) AS avg_price
    FROM
        sold_ads
    GROUP BY category) AS b ON b.category = a.category
        JOIN
    (SELECT 
        CASE
                WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
                WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
                WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
                ELSE 'Luxury'
            END AS category,
            ROUND(AVG(price)) AS avg_price
    FROM
        ad_data
    GROUP BY category) AS c ON b.category = c.category;

-- Additional Insights

SELECT 
    a.category, b.car_brand, b.occurance
FROM
    (SELECT 
        CASE
                WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
                WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
                WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
                ELSE 'Luxury'
            END AS category
    FROM
        sold_ads
    GROUP BY category
    ORDER BY CASE
        WHEN price BETWEEN 0 AND 4999 THEN 1
        WHEN price BETWEEN 5000 AND 19999 THEN 2
        WHEN price BETWEEN 20000 AND 49999 THEN 3
        ELSE 5
    END) AS a
        JOIN
    (SELECT 
        CASE
                WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
                WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
                WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
                ELSE 'Luxury'
            END AS category,
            car_brand,
            COUNT(car_brand) AS occurance
    FROM
        sold_ads
    GROUP BY category , car_brand
    ORDER BY occurance DESC , car_brand) AS b ON b.category = a.category;

-- Color preference
SELECT 
    CASE
        WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
        WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
        WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
        ELSE 'Luxury'
    END AS category,
    color,
    COUNT(color) AS occurance
FROM
    sold_ads
GROUP BY category , color
ORDER BY CASE
    WHEN price BETWEEN 0 AND 4999 THEN 1
    WHEN price BETWEEN 5000 AND 19999 THEN 2
    WHEN price BETWEEN 20000 AND 49999 THEN 3
    ELSE 5
END , occurance DESC;

SELECT 
    kms, COUNT(model) AS number_of_cars
FROM
    sold_ads
GROUP BY kms
ORDER BY CASE
    WHEN kms BETWEEN 0 AND 9999 THEN 1
    WHEN kms BETWEEN 10000 AND 19999 THEN 2
    WHEN kms BETWEEN 20000 AND 29999 THEN 3
    WHEN kms BETWEEN 30000 AND 39999 THEN 4
    WHEN kms BETWEEN 40000 AND 49999 THEN 5
    WHEN kms BETWEEN 50000 AND 59999 THEN 6
    WHEN kms BETWEEN 60000 AND 69999 THEN 7
    WHEN kms BETWEEN 70000 AND 79999 THEN 8
    WHEN kms BETWEEN 80000 AND 89999 THEN 9
    WHEN kms BETWEEN 90000 AND 99999 THEN 10
    WHEN kms BETWEEN 10000 AND 109999 THEN 11
    WHEN kms BETWEEN 110000 AND 119999 THEN 12
    WHEN kms BETWEEN 120000 AND 129999 THEN 13
    WHEN kms BETWEEN 130000 AND 139999 THEN 14
    WHEN kms BETWEEN 140000 AND 149999 THEN 15
    WHEN kms BETWEEN 150000 AND 159999 THEN 16
    WHEN kms BETWEEN 160000 AND 169999 THEN 17
    WHEN kms BETWEEN 170000 AND 179999 THEN 18
    WHEN kms BETWEEN 180000 AND 189999 THEN 19
    WHEN kms BETWEEN 190000 AND 199999 THEN 20
    ELSE 25
END;
    
SELECT 
    a.category,
    a.transmission,
    a.occurance,
    ROUND(a.occurance / b.total * 100, 2) AS percentage
FROM
    (SELECT 
        CASE
                WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
                WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
                WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
                ELSE 'Luxury'
            END AS category,
            transmission,
            COUNT(transmission) AS occurance
    FROM
        sold_ads
    GROUP BY category , transmission) AS a
        JOIN
    (SELECT 
        CASE
                WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
                WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
                WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
                ELSE 'Luxury'
            END AS category,
            COUNT(price) AS total
    FROM
        sold_ads
    GROUP BY category) AS b ON a.category = b.category
GROUP BY a.category , a.transmission
ORDER BY CASE
    WHEN a.category = 'Economy' THEN 1
    WHEN a.category = 'Standard' THEN 2
    WHEN a.category = 'Premium' THEN 3
    ELSE 5
END , a.occurance DESC;

-- Number of Extra Features required

SELECT 
    CASE
        WHEN price BETWEEN 0 AND 4999 THEN 'Economy'
        WHEN price BETWEEN 5000 AND 19999 THEN 'Standard'
        WHEN price BETWEEN 20000 AND 49999 THEN 'Premium'
        ELSE 'Luxury'
    END AS category,
    extra_features,
    COUNT(extra_features) AS occurance
FROM
    sold_ads
GROUP BY category , extra_features
ORDER BY CASE
    WHEN category = 'Economy' THEN 1
    WHEN category = 'Standard' THEN 2
    WHEN category = 'Premium' THEN 3
    ELSE 5
END , extra_features;
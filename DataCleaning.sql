CREATE TABLE ads (
    title VARCHAR(255),
    price INT,
    url VARCHAR(255),
    PRIMARY KEY (url)
);

CREATE TABLE ad_data (
    id INT,
    posted_date DATE,
    title VARCHAR(255),
    price INT,
    advertiser VARCHAR(100),
    description_length INT,
    image_number INT,
    views INT
);

CREATE TABLE car_info (
    id INT NOT NULL,
    car_brand VARCHAR(50),
    body_type VARCHAR(25),
    color VARCHAR(25),
    extra_features INT,
    kms VARCHAR(50),
    model VARCHAR(50),
    transmission VARCHAR(50),
    production_year YEAR,
    PRIMARY KEY (id)
);
    
CREATE TEMPORARY TABLE ads_temp (
	title VARCHAR(255),
    price VARCHAR(255),
    url VARCHAR(255));
    
-- Adding Data into the ads table. We will also need to clean some rows as the price column may have additional '$' characters.

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ads.txt'
INTO TABLE ads_temp
FIELDS TERMINATED BY '$$$'
LINES TERMINATED BY '\n';

CREATE TEMPORARY TABLE ads_temp2 AS
Select title, (Replace(price, '$','') + 0) as price, url from ads_temp;

INSERT INTO ads
SELECT DISTINCT * from ads_temp2;


-- Adding data into the ad_data table.alter

CREATE temporary table ad_data_temp (
    id INT,
    posted_date DATE,
    title VARCHAR(255),
    price varchar(255),
    advertiser VARCHAR(100),
    description_length INT,
    image_number INT,
    views INT,
    na varchar(1)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ad_data_list.txt'
INTO TABLE ad_data_temp
FIELDS TERMINATED BY '$$$'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TEMPORARY TABLE ad_data_temp2 AS
Select DISTINCT id, posted_date, title, (Replace(price, '$','') + 0) as price, advertiser, description_length, image_number, views from ad_data_temp;

INSERT INTO ad_data
SELECT DISTINCT * from ad_data_temp2;

DROP TEMPORARY TABLE ad_data_temp2;
DROP TEMPORARY TABLE ad_data_temp;

-- Noticed that some IDs occure more than once, which prevented us from setting the field IDs as primary keys

SELECT 
    id, COUNT(id)
FROM
    ad_data
GROUP BY id
ORDER BY COUNT(id) DESC; 

Create temporary table ad_data_temp as
SELECT 
    a.id,
    a.posted_date,
    a.title,
    GREATEST(a.price, b.price, c.price) AS price,
    a.advertiser,
    a.description_length,
    a.image_number,
    GREATEST(a.views, b.views, c.views) AS views
FROM
    ad_data AS a
        JOIN
    ad_data AS b ON a.id = b.id AND a.views < b.views
        JOIN
    ad_data AS c ON b.id = c.id AND b.views < c.views
ORDER BY a.id;

DELETE FROM ad_data 
WHERE
    id IN (SELECT 
        id
    FROM
        ad_data_temp);

insert into ad_data
select * from ad_data_temp;

-- Adding data into car_info table

DROP temporary table car_info_temp;
CREATE Temporary TABLE car_info_temp (
    id INT,
    car_brand VARCHAR(50),
    body_type VARCHAR(25),
    color VARCHAR(25),
    extra_features varchar(10),
    kms VARCHAR(50),
    model VARCHAR(50),
    transmission VARCHAR(50),
    production_year YEAR,
    na VARCHAR(1)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\car_info_list.txt'
INTO TABLE car_info_temp
FIELDS TERMINATED BY '$$$'
LINES TERMINATED BY '\n';

ALTER TABLE car_info_temp
DROP COLUMN na;

-- Cleaning columns extra_features and model to remove any blank.

create temporary table car_info_temp2 as
SELECT 
    id,
    car_brand,
    body_type,
    color,
    (REPLACE(extra_features, ' ', '0') + 0) AS extra_features,
    kms,
    model,
    transmission,
    production_year
FROM
    car_info_temp;

UPDATE car_info_temp2 
SET 
    model = NULL
WHERE
    model = '' OR model = ' ';

insert into car_info
select distinct * from car_info_temp2;

CREATE TABLE updates (
    id INT,
    updated_date DATE,
    published VARCHAR(1),
    views INT,
    url VARCHAR(255)
);
    
DROP TEMPORARY TABLE IF EXISTS  ad_update_temp;
CREATE TEMPORARY TABLE ad_update_temp (
	id varchar(20),
    updated_date DATE,
    published VARCHAR(1),
    views varchar(10),
    URL varchar (255),
    na varchar(1)
    );
    
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ad_update.txt'
INTO TABLE ad_update_temp
FIELDS TERMINATED BY '$$$'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS ;

CREATE TEMPORARY TABLE ad_update_temp2 as
SELECT 
    *
FROM
    ad_update_temp
WHERE
    id = ''
ORDER BY published;

CREATE TEMPORARY TABLE ad_update_temp3 as
SELECT 
    *
FROM
    ad_update_temp
WHERE
    id <> '';

ALTER TABLE ad_update_temp3
DROP COLUMN na;

CREATE TEMPORARY TABLE ad_update_temp4 as
(SELECT DISTINCT
    b.id, a.updated_date, a.published, a.views, a.URL
FROM
    ad_update_temp2 a
        LEFT JOIN
    ad_update_temp b ON a.URL = b.URL AND b.published = 'Y'
ORDER BY a.updated_date , URL) UNION (SELECT DISTINCT
    *
FROM
    ad_update_temp3
ORDER BY updated_date , URL);

CREATE TABLE ad_update AS SELECT id + 0 AS id, updated_date, published, views, URL AS url FROM
    ad_update_temp4
ORDER BY updated_date , published , id;

DROP TEMPORARY TABLE IF EXISTS updates_temp;
CREATE TEMPORARY TABLE updates_temp as
(SELECT 
    id, MIN(updated_date) as updated_date, published, views, url
FROM
    ad_update
WHERE
    published = 'N'
GROUP BY url)
UNION
(SELECT 
    id, updated_date, published, views, url
FROM
    ad_update
WHERE
    published = 'Y');

UPDATE updates_temp 
SET 
    views = NULL
WHERE
    views = '';

insert into updates
SELECT 
    *
FROM
    updates_temp
ORDER BY updated_date , published , id;

drop table ad_update;


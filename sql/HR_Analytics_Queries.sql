--SQL Queries Used...

--1. Which departments have the greatest attrition exposure from overtime?

SELECT
    department,
    COUNT(*) FILTER (WHERE over_time = 'Yes') AS overtime_employees,
    COUNT(*) FILTER (
        WHERE over_time = 'Yes' AND attrition = 'Yes'
    ) AS overtime_departures,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE over_time = 'Yes' AND attrition = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE over_time = 'Yes'), 0),
        2
    ) AS overtime_attrition_rate
FROM hr_employee_data
GROUP BY department
ORDER BY overtime_attrition_rate DESC;

--2. Where is attrition concentrated?

SELECT
    department,
    job_role,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left,
    ROUND(
        100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS attrition_rate
FROM hr_employee_data
GROUP BY department, job_role
ORDER BY attrition_rate DESC;

--3. How does attrition vary across salary levels?

SELECT
    salary_slab,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE attrition = 'Yes') AS employees_left,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE attrition = 'Yes')
        / COUNT(*),
        2
    ) AS attrition_rate
FROM hr_employee_data
GROUP BY salary_slab
ORDER BY attrition_rate DESC;

--4. Which job roles account for the largest share of all departures?

SELECT
    job_role,
    COUNT(*) FILTER (WHERE attrition = 'Yes') AS employees_left,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE attrition = 'Yes')
        / SUM(COUNT(*) FILTER (WHERE attrition = 'Yes')) OVER (),
        2
    ) AS share_of_total_departures,
    RANK() OVER (
        ORDER BY COUNT(*) FILTER (WHERE attrition = 'Yes') DESC
    ) AS departure_rank
FROM hr_employee_data
GROUP BY job_role
ORDER BY departure_rank;

--5. What does the typical employee who leaves look like compared with one who stays?

SELECT
    attrition,
    COUNT(*) AS employees,
    ROUND(AVG(age), 1) AS avg_age,
    ROUND(AVG(monthly_income), 2) AS avg_income,
    ROUND(AVG(years_at_company), 2) AS avg_tenure,
    ROUND(AVG(distance_from_home), 2) AS avg_distance,
    ROUND(AVG(job_satisfaction), 2) AS avg_job_satisfaction,
    ROUND(AVG(years_since_last_promotion), 2) AS avg_years_since_promotion
FROM hr_employee_data
GROUP BY attrition;

--6. Which employee-experience factors show the largest differences in attrition?

SELECT
    job_satisfaction,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE attrition = 'Yes') AS employees_left,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE attrition = 'Yes')
        / COUNT(*),
        2
    ) AS attrition_rate
FROM hr_employee_data
GROUP BY job_satisfaction
ORDER BY job_satisfaction;

--7. Which employees fall into a high-priority retention segment?

SELECT
    emp_id,
    department,
    job_role,
    years_at_company,
    job_satisfaction,
    over_time,
    monthly_income
FROM hr_employee_data
WHERE attrition = 'Yes'
  AND years_at_company <= 2
  AND over_time = 'Yes'
  AND job_satisfaction <= 2
ORDER BY years_at_company;

--8. Which tenure stage has the highest attrition?

SELECT
    CASE
        WHEN years_at_company <= 2 THEN '0-2 years'
        WHEN years_at_company <= 5 THEN '3-5 years'
        WHEN years_at_company <= 10 THEN '6-10 years'
        WHEN years_at_company <= 15 THEN '11-15 years'
        ELSE '16+ years'
    END AS tenure_group,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE attrition = 'Yes') AS employees_left,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE attrition = 'Yes')
        / COUNT(*),
        2
    ) AS attrition_rate
FROM hr_employee_data
GROUP BY
    CASE
        WHEN years_at_company <= 2 THEN '0-2 years'
        WHEN years_at_company <= 5 THEN '3-5 years'
        WHEN years_at_company <= 10 THEN '6-10 years'
        WHEN years_at_company <= 15 THEN '11-15 years'
        ELSE '16+ years'
    END
ORDER BY attrition_rate DESC;

--9. Which employee segments have the highest attrition 
-- when overtime and job satisfaction are considered together?

SELECT
    over_time,
    job_satisfaction,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE attrition = 'Yes') AS employees_left,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE attrition = 'Yes')
        / COUNT(*),
        2
    ) AS attrition_rate
FROM hr_employee_data
GROUP BY over_time, job_satisfaction
HAVING COUNT(*) >= 20
ORDER BY attrition_rate DESC;

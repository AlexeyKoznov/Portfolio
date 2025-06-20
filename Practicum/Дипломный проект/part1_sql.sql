-- 1. Вычислим общие значения ключевых показателей сервиса за весь период: 
-- общая выручка с заказов, количество заказов, средняя стоимость заказа, общее число уникальных клиентов.

SELECT currency_code,
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       AVG(revenue) AS avg_revenue_per_order,
       COUNT(DISTINCT user_id) AS total_users
FROM afisha.purchases
GROUP BY 1
ORDER BY SUM(revenue) DESC

-- 2. Изученим распределение выручки в разрезе устройств

-- Настройка параметра synchronize_seqscans важна для проверки
WITH set_config_precode AS (
  SELECT set_config('synchronize_seqscans', 'off', true)
)

SELECT device_type_canonical,
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       AVG(revenue) AS avg_revenue_per_order,
       ROUND((SUM(revenue) / SUM(SUM(revenue)) OVER())::numeric, 3) AS revenue_share
FROM afisha.purchases
WHERE currency_code = 'rub'
GROUP BY 1
ORDER BY 5 DESC

-- 3. Изученим распределения выручки в разрезе типа мероприятий

SELECT event_type_main,
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       AVG(revenue) AS avg_revenue_per_order,
       COUNT(DISTINCT event_name_code) AS total_event_name,
       AVG(tickets_count) AS avg_tickets,
       SUM(revenue) / SUM(tickets_count) AS avg_ticket_revenue,
       ROUND((SUM(revenue) / SUM(SUM(revenue)) OVER ())::numeric, 3) AS revenue_share
FROM afisha.purchases AS p 
LEFT JOIN afisha.events AS e ON p.event_id = e.event_id
WHERE currency_code = 'rub'
GROUP BY 1
ORDER BY 3 DESC

-- 4. Изучим динамику изменения значений ключевых метрик и параметров:
-- изменение выручки, количества заказов, уникальных клиентов и средней стоимости одного заказа в недельной динамике

SELECT DATE_TRUNC('week', created_dt_msk)::date AS week,
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       COUNT(DISTINCT user_id) AS total_users,
       SUM(revenue) / COUNT(order_id) AS revenue_per_order
FROM afisha.purchases AS p
WHERE currency_code = 'rub'
GROUP BY 1
ORDER BY 1

-- 5. Выведим топ-7 регионов по значению общей выручки:

SELECT region_name,
       SUM(revenue) AS total_revenue,
       COUNT(order_id) AS total_orders,
       COUNT(DISTINCT user_id) AS total_users,
       SUM(tickets_count) AS total_tickets,
       SUM(revenue) / SUM(tickets_count) AS one_ticket_cost
FROM afisha.purchases AS p 
JOIN afisha.events AS e ON p.event_id = e.event_id
JOIN afisha.city AS c ON e.city_id = c.city_id
JOIN afisha.regions AS r ON c.region_id = r.region_id
WHERE currency_code = 'rub'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 7
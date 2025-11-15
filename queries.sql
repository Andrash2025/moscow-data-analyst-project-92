SELECT					-- Выбераем
COUNT(customer_id) as customers_count 	-- счет по полколонке customer_id с указанием псевдонима колонки как customers_count
FROM customers 				-- из таблицы customers

-- 5 задание в проекте
--1.Подготовьте в файл top_10_total_income.csv отчет с продавцами у которых наибольшая выручка
select                           					-- Выбираем поля
  concat(e.first_name,' ', e.last_name) as seller,  			-- Выбираем first_name и last_name "склеевая" их с помощью функции concat и присваевая псевдоним seller
  COUNT(s.sales_id) as operation,            				-- Считаем количество продаж каждого менеджера по колонке sales_id присваевая псевдоним operation
  Floor(SUM (s.quantity * p.price )) as income   			-- Создаем новую колонку сумарная выручка продавца за весь период умножая количество продаж на сумму кругляя в меньшую сторону income
FROM sales as s                      					-- Левая таблица sales устанавливаем псевдоним s  
left join employees as e                				-- Присоеденяем левым соединением таблицу employees устанавливаем псевдоним e
on s.sales_person_id = e.employee_id          				-- Соединяем две таблицы по столбцам s.sales_person_id = e.employee_id
left join products as p                  				-- Присоеденяем левым соединением таблицу products устанавливаем псевдоним p
on s.product_id = p.product_id              				-- Соединяем две таблицы по столбцам s.product_id = p.product_id
group by seller                      					-- Группируем итоговую выборку по столбцу seller
order by income DESC                  					-- Упорядочиваем итоговую выборку по столбцу income в порядке убывания
limit 10;                        					-- Выводим первые 10 записей итоговой таблицы т.к. по условию задачи нам нужны  топ 10 продавцов у которых наибольшая выручка

-- 2.Подготовьте в файл lowest_average_income.csv отчет с продавцами, чья выручка ниже средней выручки всех продавцов
with raschet as(							-- Для решения задачи используем обобщённое табличное выражение, CTE.					
select                        						-- Выбираем поля
  concat(e.first_name,' ', e.last_name) as seller,  			-- Выбираем first_name и last_name "склеевая" их с помощью функции concat и присваевая псевдоним seller
  COUNT(s.sales_id) as operation,            				-- Считаем количество продаж каждого менеджера по колонке sales_id присваевая псевдоним operation
  Floor(SUM (s.quantity * p.price )) as income,				-- Создаем новую колонку сумарная выручка продавца за весь период умножая количество продаж на сумму кругляя в менбшую сторону come
  Floor(AVG(s.quantity * p.price)) as average_income,			-- Расчитываем среднюю выручку по каждому продавцу с помощью деления суммы его выручки на сумму количества его сделок
  SUM(SUM(s.quantity * p.price)) over() as all_income,			-- Рассчитываем сумму выручки всех продавцов путем сложения всех сумм выручек всех продавцов
  SUM(COUNT(s.sales_id)) over() as all_operation,	 		-- Рассчитываем сумму всех продаж всех продавцов	
  FLOOR(SUM(SUM(s.quantity * p.price)) over()/ SUM(COUNT(s.sales_id)) over())as avg_all -- Рассчитываем сдеднее значение суммы продаж по всем продавцам с помощью оконных функций путем деления общей суммы на общее количество продаж
FROM sales as s                      					-- Левая таблица sales устанавливаем псевдоним s  
left join employees as e                				-- Присоеденяем левым соединением таблицу employees устанавливаем псевдоним e
on s.sales_person_id = e.employee_id          				-- Соединяем две таблицы по столбцам s.sales_person_id = e.employee_id
left join products as p                  				-- Присоеденяем левым соединением таблицу products устанавливаем псевдоним p
on s.product_id = p.product_id 						-- Соединяем две таблицы по столбцам s.product_id = p.product_id
group by seller								-- Группируем по продавцам						
)
select 									-- Основной запрос. Выбераем поля
seller,									-- Продавец
average_income								-- Среднюю сумарная выручки продавца
from raschet								-- Из CTE таблицы aschet
where average_income < avg_all						-- Задаем условие отбора, тех продавцов средняя общая выручка, которых меньше общей средней выручки
order by average_income desc;						-- Упорядочиваем выборку по средней выручке продавца по убывания

--3. Подготовьте в файл day_of_the_week_income.csv отчет с данными по выручке по каждому продавцу и дню недели
WITH sales_by_day AS (							-- Для решения задачи используем обобщённое табличное выражение, CTE.
  select								-- Выбираем поля
    concat(e.first_name, ' ', e.last_name) AS seller,			-- Выбираем first_name и last_name "склеевая" их с помощью функции concat и присваевая псевдоним seller
    trim(to_char(s.sale_date, 'Day')) AS day_of_week,       		-- Выбераем день из даты с помощью Day, приобразуем в текст, удаляем лишние пробелы, присваиваем псевдоним
    extract(isodow from s.sale_date) AS day_number,			-- Извлекаем порядковый день недели
    FLOOR(SUM(s.quantity * p.price)) AS income				-- Создаем новую колонку сумарная выручка продавца за весь период умножая количество продаж на сумму кругляя в меньшую сторону income
  FROM sales as s							-- Левая таблица sales устанавливаем псевдоним s
  LEFT JOIN employees as e 						-- Присоеденяем левым соединением таблицу employees устанавливаем псевдоним e
  on s.sales_person_id = e.employee_id 					-- Соединяем две таблицы по столбцам s.sales_person_id = e.employee_id
  LEFT JOIN products as p 						-- Присоеденяем левым соединением таблицу products устанавливаем псевдоним p
  on s.product_id = p.product_id					-- Соединяем две таблицы по столбцам s.product_id = p.product_id
  GROUP BY seller, day_of_week, day_number				-- Группируем 
)
select									-- Основной запрос. Выбераем поля
  seller,														
  day_of_week,
  income
FROM sales_by_day							-- Из CTE таблицы sales_by_day
ORDER by day_number, seller;						-- Упорядочиваем итоговую таблицу


-- 6 Задание проекта

-- 1. Подготовьте в файл age_groups.csv с возрастными группами покупателей
select									-- Выбираем поля
case WHEN age >= 16 and age <= 25 then '16-25'				-- Используя условный оператор case задаем условия для формирования возрастных групп
	 WHEN age >= 26 and age <= 40 then '26-40'
	 else '40+'
end age_category,							-- Задаем псевдоним после разделения на группы
COUNT(customer_id) as age_count						-- Считаем количество человек в возрвстных группах и задаем псевдоним
from customers								-- Наименование ьаблицы из которой осуществляется выборка
group by age_category							-- Групперуем по возрвстным категориям
order by age_category							-- Сортируем по возрастным категориям в порядке возрастания

-- 2. Подготовьте в файл customers_by_month.csv с количеством покупателей и выручкой по месяцам
WITH sales_by_month AS (						-- Для решения задачи используем обобщённое табличное выражение, CTE.	
select									-- Выбираем поля
	EXTRACT(YEAR FROM s.sale_date)::TEXT || '-' || LPAD(EXTRACT(MONTH FROM s.sale_date)::TEXT, 2, '0') AS selling_month, -- Извлекаем и склеиваем гол и месяц
	COUNT(c.customer_id) as total_customers,			--Считаем количество клиентов
	floor(SUM(s.quantity * p.price)) as income			-- Считаем суммы потраченных клиентами средств
from sales as s								-- Соединяем таблицы по услокиям
left join customers as c
on s.customer_id = c.customer_id 
left join products as p
on s.product_id = p.product_id
group by selling_month							-- Группируем тпо месяцу продажи
)
select									-- Основной запрос. Выбераем поля	
  selling_month,														
  total_customers,
  income
from sales_by_month							-- Из CTE таблицы sales_by_month			
order by selling_month;							-- Группируем данные 


-- 3. Подготовьте в файл special_offer.csv с покупателями первая покупка которых пришлась на время проведения специальных акций
with discount as (							-- Для решения задачи используем обобщённое табличное выражение, CTE.	
  select 
    c.customer_id,
    concat(c.first_name, ' ', c.last_name) AS customer,
    e.first_name || ' ' || e.last_name AS seller,
    s.sale_date,
    p.price,
    ROW_NUMBER() over (partition by c.customer_id order by s.sale_date) as rn --Использовуем оконную функцию ROW_NUMBER(), чтобы выбрать первый заказ каждого клиента
  from sales s
  left join customers as c on s.customer_id = c.customer_id		-- Соединяем таблицы по услокиям
  left join employees as e on s.sales_person_id = e.employee_id
  left join products as p on s.product_id = p.product_id
)
select									-- Основной запрос
	customer,							-- Выбераем поля
	sale_date,
 	seller	
from discount								-- Из CTE таблицы discount
where rn = 1 AND price = 0						-- Условия первая покупка клиента по цене 0
order by customer_id;							-- Упоряддочиваем по customer_id
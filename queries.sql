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
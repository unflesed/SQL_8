-- 2 Создать базу данных с именем MyFunkDB
create database MyFunkDB;
drop database if exists MyFunkDB;

use MyFunkDB;

-- 3 В данной базе данных создать 3 таблицы:
-- В 1-й содержатся имена и номера телефонов сотрудников некоторой компании.
-- Во 2-й Ведомости об их зарплате, и должностях: главный директор, менеджер, рабочий.
-- В 3-й семейном положении, дате рождения, где они проживают.
create table Employees(
id int auto_increment not null,
name varchar(30) not null,
phone varchar(30) not null,
primary key(id)
);

create table Salaries(
id int auto_increment not null,
Empl_id int not null,
salary int not null,
post varchar(30) not null,
foreign key (Empl_id) references Employees(id),
primary key(id)
);

create table Info(
id int auto_increment not null,
Empl_id int not null,
family tinyint not null,
dateOfBirth date not null,
address varchar(30) not null,
foreign key (Empl_id) references Employees(id),
primary key(id)
);

insert into Employees (name, phone)
values ('Pupkin', '+19800101'),
('Utkin', '+19810101'),
('Ivanov', '+19820101'),
('Petrov', '+19830101'),
('Sidorov', '+19840101'),
('Antonov', '+19850101');

insert into Salaries (Empl_id, salary, post)
values (1, 1000, 'worker'),
(2, 1100, 'worker'),
(3, 1200, 'worker'),
(4, 1500, 'manager'),
(5, 1600, 'manager'),
(6, 2500, 'chief');

insert into Info (Empl_id, family, dateOfBirth, address)
values (1, 1, 19800101, 'Lenina 12'),
(2, 1, 19810101,'Pushkina 10'),
(3, 1, 19820101,'Shevchenko 11'),
(4, 0, 19830101,'Kolasa 5'),
(5, 0, 19840101, 'Kupaly 3'),
(6, 0, 19850101, 'Cetkin 5');

select * from Employees;
select * from Salaries;
select * from Info;

-- 4 Выполните ряд записей вставки в виде транзакции в хранимой процедуре. Если такой сотрудник
-- имеется откатите базу данных обратно.
DELIMITER |
drop procedure if exists insertEmpl; |
CREATE procedure insertEmpl(IN nameE varchar(30), IN phoneE varchar(30), IN SalaryE int, IN postE varchar(30), 
								IN familyE tinyint, IN dateE date, IN addressE varchar(30))
begin
declare idd int;
start transaction;
	INSERT Employees (name, phone)
    VALUES (nameE, phoneE);
    SET idd = @@identity;
    
	insert Salaries (Empl_id, salary, post)
    values (idd, SalaryE, postE);
    
    INSERT Info (Empl_id, family, dateOfBirth, address)
    values (idd, familyE, dateE, addressE);
	
    IF exists (Select * from Employees where name = nameE and phone = phoneE and id != idd)
		then
			rollback;
		end if;
end; |

CALL insertEmpl('Yakimenko', '+123456789', 1111, 'manager', 1, 19810101, 'Lenina 11'); |

CALL insertEmpl('Yakimenko', '+123456789', 1111, 'manager', 1, 19810101, 'Lenina 11'); |


-- 5 Создайте триггер, который будет удалять записи со 2-й и 3-й таблиц перед удалением записей из таблиц
-- сотрудников (1-й таблицы), чтобы не нарушить целостность данных.
drop trigger if exists delete_empl; |

create trigger delete_empl
before delete on Employees
for each row
begin
		delete from info where Empl_id = OLD.id;
		delete from Salaries where Empl_id = OLD.id;
end; |

delete from Employees where id = 7; |

select * from Employees; |
select * from Salaries; |
select * from Info; |
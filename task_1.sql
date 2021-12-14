use Publishing;

-- 1. Используя транзакцию добавьте несколько записей в любую из таблиц.
start transaction;

Insert country (NameCountry)
values ('Belarus');

Insert country (NameCountry)
values ('Russia');

commit;
select * from country;

-- 2. Используя транзакцию добавьте несколько записей в любую из таблиц, а потом откатите ее.
start transaction;

Insert shop(country_id, NameShop)
values (1, 'Ozz');

Insert shop(country_id, NameShop)
values (2, 'Ozon');

rollback;
select * from shop;

-- 3. Используя транзакцию создайте точку, к кторой необходимо будет откатить транзакцию, 
-- добавьте несколько записей в любую из таблиц, а потом откатите ее до этой точки.
start transaction;

Insert themes (NameTheme)
values ('qwerty');

savepoint pointSaved;

Insert themes (NameTheme)
values ('asdfg');

rollback to savepoint pointSaved;

commit;
select * from themes;

-- 4. Создайте триггер, который при удалении книги, копирует данные о ней в отдельную таблицу "DeletedBooks".
drop table if exists DeletedBooks;
create table DeletedBooks(
id int auto_increment not null,
theme_id int,
author_id int,
NameBook varchar(30),
PriceOfBook  int,
DrawingOfBook int,
pages int,
foreign key (theme_id) references themes(id),
foreign key (author_id) references author(id),
primary key(id));

DELIMITER |
create trigger on_delete
before delete on book
for each row
begin
	insert into DeletedBooks(nameBook, DrawingOfBook, pages) 
    select b.nameBook, b.DrawingOfBook, b.pages
    from book as b
    where b.id = OLD.id;
end; |

drop trigger if exists on_delete; |
delete from book where id = 19; |
select * from DeletedBooks; |

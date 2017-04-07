drop table if exists node;
drop function if exists f(int);
drop function if exists f2(int[]);
drop function if exists g(int[]);

create table node(id int primary key, parent_id int);

insert into node values
	(0, null),
	(1, 0),
	(2, 0),
	(3, 2),
	(4, 0),
	(5, 1),
	(6, 1),
	(7, 1),
	(8, 2),
	(9, 3),
	(10, 3);

create function f(p_id int)
returns table (id int, parent_id int)
as $$
	select * from node where node.parent_id = p_id;
$$ language sql stable;

create function f2(p_ids int[])
returns table (id int, parent_id int)
as $$
	select * from node where node.parent_id = ANY ( p_ids );
$$ language sql stable;

create function g(p_ids int[])
returns table (id int, parent_id int, x int)
as $$
	with recursive res(id, parent_id, i) as (
		select null::int, null::int, array_lower(p_ids, 1)
		union all
		select tmp.id, tmp.parent_id, res.i + 1
		from res, f(p_ids[res.i]) as tmp
		where res.i <= array_upper(p_ids, 1)
	) select res.* from res where id is not null;
$$ language sql stable;

select * from f(2);

select * from f2(ARRAY[2, 1]);

select * from g(ARRAY[2, 1]);


explain analyze select * from f(2);

explain analyze select * from f2(ARRAY[2, 1]);

explain analyze select * from g(ARRAY[2, 1]);


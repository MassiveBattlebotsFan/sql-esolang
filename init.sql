\pset tuples_only on
\i runner.sql

create table cmds(id int,command int,arg int);
insert into cmds values (-1,0,0);
create or replace function parse_file(file text) returns void as $$
  declare
    t record;
    tmp int;
  begin
    create temp table tmp(l text);
    file := quote_literal(file);
    execute 'copy tmp from '||file;
    for t in select * from tmp loop
      select id from cmds order by id desc limit 1 into tmp;
      insert into cmds values (tmp+1,split_part(t.l,',',1)::int,split_part(t.l,',',2)::int);
    end loop;
    delete from cmds where id=-1;
  end;
$$ language plpgsql;

\prompt 'enter script name: ' fname

select parse_file(:'fname');
select parse_cmds();
select * from cmds;

\i end.sql

\pset tuples_only on
\i runner.sql

create table cmds(command int,arg int);

create or replace function parse_file(file text) returns void as $$
  declare
    t record;
  begin
    create temp table tmp(l text);
    file := quote_literal(file);
    execute 'copy tmp from '||file;
    for t in select * from tmp loop
      insert into cmds values (split_part(t.l,',',1)::int,split_part(t.l,',',2)::int);
    end loop;
  end;
$$ language plpgsql;

\prompt 'enter script name: ' fname

select parse_file(:'fname');
select parse_cmds();
select * from cmds;

\i end.sql

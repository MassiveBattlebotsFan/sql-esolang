create table stack(id int, s int);
insert into stack values (0,0);
create or replace function push(val int) returns void as $$
  declare
    tmp int;
  begin
    select id from stack order by id desc limit 1 into tmp;
    insert into stack values (tmp+1, val);
  end;
$$ language plpgsql;

create or replace function pop() returns int as $$
  declare
    tmp int;
    tmpid int;
  begin
    select id,s from stack order by id desc limit 1 into tmpid,tmp;
    if tmpid = 0 then
      raise 'stack underflow';
    end if;
    delete from stack where id=tmpid;
    return tmp;
  end;
$$ language plpgsql;

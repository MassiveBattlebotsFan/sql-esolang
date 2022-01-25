\i stack.sql

create table jump_points(l int, id int);
insert into jump_points values(0,0);
create or replace function parse_cmds() returns void as $$
  declare
    t record;
    i record;
    tmp int;
    acc int;
    print_buffer text;
    end_command int;
  begin
    acc := 0;
    print_buffer := '';
    select id from cmds order by id desc limit 1 into end_command;
    <<main>>
    loop
      --raise notice 'cmd: %, arg: %',t.command,t.arg;
      select * from cmds where id=acc limit 1 into t;
      if t.command = 0 then
        perform push(t.arg);
      elsif t.command = 1 then
        perform push(pop() + pop());
      elsif t.command = 2 then
        if t.arg = 0 then
          raise notice '%', print_buffer;
          print_buffer := '';
        elsif t.arg > 0 then
          for i in 1..t.arg loop
            print_buffer := print_buffer || chr(pop());
          end loop;
        else
          raise notice '%', chr(pop());
        end if;
      elsif t.command = 3 then
        if t.arg > 0 then
          select id from jump_points where id=t.arg order by id desc limit 1 into tmp;
          if tmp = null then
            insert into jump_points values (acc,t.arg);
          else
            update jump_points set l=acc where id=tmp;
          end if;
        elsif t.arg = 0 then
          select pop() into tmp;
          perform push(tmp);
          if tmp <> 0 then
            select id,l from jump_points order by id desc limit 1 into tmp,acc;
            --raise notice 'acc: %', acc;
            delete from jump_points where id = tmp;
            if tmp = 0 then
              insert into jump_points values (0,0);
            end if;
            perform push(pop()-1);
          end if;
        end if;
      elsif t.command = 4 then
        for i in select id,s from stack order by id desc limit t.arg loop
          raise notice 'id: %, val: %', i.id,i.s;
        end loop;
      end if;
    --raise notice 'acc: %',acc;
    exit when acc=end_command;
    acc := acc + 1;
    end loop;
  end;
$$ language plpgsql;

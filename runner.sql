\i stack.sql

create or replace function parse_cmds() returns void as $$
  declare
    t record;
    i record;
    acc int;
    print_buffer text;
  begin
    acc := 0;
    print_buffer := '';
    for t in select * from cmds loop
      --raise notice 'cmd: %, arg: %',t.command,t.arg;
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
          raise 'invalid print command';
        end if;
      elsif t.command = 3 then
        perform pop();
      elsif t.command = 4 then
        for i in select id,s from stack order by id desc limit t.arg loop
          raise notice 'id: %, val: %', i.id,i.s;
        end loop;
      end if;
    end loop;
  end;
$$ language plpgsql;

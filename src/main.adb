with Ada.Text_IO; use Ada.Text_IO;

procedure main is
   NumElements : constant := 1000;
   type my_array is array (1 .. NumElements) of Integer;

   a : my_array;
   size, new_size: Integer;

   procedure create_array is
   begin
      for i in a'Range loop
         a (i) := i;
      end loop;
   end create_array;

   protected task_manager is
      procedure set_task_count(cnt : in Integer);
      procedure synch;
      entry wait_finish;
   private
      total_tasks  : Integer := 0;
      task_counter : Integer := 0;
   end task_manager;

   protected body task_manager is
      procedure set_task_count (cnt : in Integer) is
      begin
         total_tasks := cnt;
         task_counter := 0;
      end set_task_count;

      procedure synch is
      begin
         task_counter := task_counter + 1;
      end synch;

      entry wait_finish when task_counter = total_tasks is
      begin
         null;
      end wait_finish;

   end task_manager;

   task type my_task is
       entry start (left, right : in Integer; last_iteration: in Boolean);
   end my_task;

   task body my_task is
      left, Right : Integer;
      last_iteration: Boolean := False;
   begin
      loop
         accept start (left, right : in Integer; last_iteration: in Boolean) do
            my_task.left  := left;
            my_task.right := right;
            my_task.last_iteration := last_iteration;
         end start;

         a(my_task.left) :=  a(my_task.left) + a(my_task.right);
         task_manager.synch;
         exit when my_task.last_iteration;

      end loop;
   end my_task;

   tasks : array (1 .. NumElements/2) of my_task;
begin
   create_array;

   size := NumElements;

   while size > 1 loop
      task_manager.set_task_count(size/2);
      new_size := size/2 + (size mod 2);

      for i in 1..size/2 loop
         tasks(i).start(i, size - i + 1, i>new_size/2);
      end loop;

      task_manager.wait_finish;

      size := new_size;
   end loop;

   Put_Line ("Multi-thread sum: " & a(1)'Img);

end main;

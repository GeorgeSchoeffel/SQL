#George Schoeffel


use RDS_MySQL_v8_GJS47;

select name, ID,
	(select count(*) as courses)
from student, takes
where student.ID = takes.ID and
	students.department = 'Statistics' and
    name like 'S%' and
    where sum(takes);

with statistic_student(name, ID) as
	(select name, ID
    from student
    where name like 'S%' and
		student.dept_name = 'Statistics'),
	cybernetics(name, ID, num_course) as
	(select student.name, student.ID, count(distinct takes.course_id) as num_course
	from statistic_student, takes, course
	where takes.ID = statistic_student.ID and
	takes.course_id = course.course_id and
    course.dept_name = 'Cybernetics'
group by takes.course_id
having count(takes.ID) < 9);

with cybernetics(ID, value) as 
	(select distinct takes.ID, count(takes.course_ID)
    from course, takes
    where course.course_id = takes.course_id and
		course.dept_name = 'Cybernetics'
        group by takes.ID)
select distinct student.name, student.ID
from student, takes, course, cybernetics
where student.ID = takes.ID and
	takes.course_id = course.course_id and
    cybernetics.ID = student.ID and
    student.name like 'S%' and
    student.dept_name = 'Statistics' and
    cybernetics.value < 9;

select name, id
from student
where name like 'S%' and
	dept_name = 'Statistics';
    
select name, ID, rank() over (order by(tot_cred) desc) as credits_rank
	from student
    order by credits_rank;
    
select ID, name
from instructor as teacher
where not exists 
( select *
from teaches, takes, instructor
where teaches.ID = instructor.ID and 
	takes.course_id = teaches.course_id and 
   	teacher.id = instructor.ID and 
   	(grade='A' or grade='A-' or grade='A+') 
    	);

select course_id
from instructor, teaches
where instructor.ID = teaches.ID and
	name = 'Konstantinides';

create table prereq1 (
	course_id varchar(8) not null,
    prereg_id varchar(8) not null,
    primary key(course_id, prereg_id)
);
insert into prereg1 
select * 
from prereq;

create table prereq1 select * from prereq;

select * from prereq1;

select name, salary
from instructor as teacher
where not exists
(select *
from teaches, instructor, course
where teaches.ID = instructor.ID and teacher.ID=instructor.ID and
instructor.dept_name = course.dept_name and course.course_id = teaches.course_id);

delete from prereq1
	where course_id = 133 and prereq_id = 852;    
delete from prereq1
	where course_id = 634 and prereq_id = 864;

drop table prereq1

with recursive rec_prereq(course_id, prereq_id) as
	(select course_id, prereq_id
    from prereq1
union
	select rec_prereq.course_id, prereq.prereq_id,
    from rec_prereq, prereq1
    where rec_prereq.prereq_id = prereq.course_id
    )
select *
from rec_prereq1


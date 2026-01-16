create database kiemtrass15;
use kiemtrass15;

create table Students (
	StudentID char(5) primary key,
    FullName varchar(50) not null,
    TotalDebt decimal(10,2) default 0
);

create table Subjects (
	SubjectID char(5) primary key,
    SubjectName varchar(50) not null,
	Credits int check (Credits > 0)
); 

create table Grades (
	StudentID char(5),
    foreign key (StudentID) references Students(StudentID),
    SubjectID char(5),
    foreign key (SubjectID) references Subjects(SubjectID),
    primary key (StudentID, SubjectID),
    Score decimal(4,2) not null check (Score between 0 and 10)
);

create table GradeLog (
    LogID int primary key auto_increment,
    StudentID char(5),
    OldScore decimal(4,2),
    NewScore decimal(4,2),
    ChangeData datetime default current_timestamp
);
-- Kiem tra diem
delimiter //
create trigger checkscore
before insert on Grades
for each row
begin
    if new.score < 0 then
        set new.score = 0;
    elseif new.score > 10 then
        set new.score = 10;
    end if;
end//
delimiter ;

-- Them 1 sinh vien moi
start transaction;
insert into Students (StudentID, FullName)
values ('SV02', 'Ha Bich Ngoc');
update Students
set TotalDebt = 5000000
where StudentID = 'SV02';
commit;

-- Ghi log khi cap nhat diem
delimiter //
create trigger LogGradeUpdate
after update on Grades
for each row
begin
    if old.Score <> new.Score then
        insert into GradeLog (StudentID, OldScore, NewScore, ChangeData)
        values (old.StudentID, old.Score, new.Score, now());
    end if;
end//
delimiter ;

-- Dong hoc phi 
delimiter //
create procedure paytuition()
begin
    declare newdebt decimal(10,2);
    start transaction;
    update Students
    set TotalDebt = TotalDebt - 2000000
    where StudentID = 'SV01';
    select TotalDebt into newdebt
    from Students
    where StudentID = 'SV01';
    if newdebt < 0 then
        rollback;
    else
        commit;
    end if;
end//
delimiter ;


-- Khong sua diem khi da qua mon
delimiter //
create trigger tg_PreventPassUpdate
before update on Grades
for each row
begin
    if old.Score >= 4.0 then
        signal sqlstate '45000'
        set message_text = 'Sinh vien da qua mon!!';
    end if;
end//
delimiter ;

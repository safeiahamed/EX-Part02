Use UniversityResearchSystem
--Q1
select R.FirstName+' '+ R.LastName FullName,Rp.Id, RP.Title
from Researcher R left join WorksOn W
on R.Id = W.ResearcherId
left join ResearchProject RP 
on W.ProjectId = RP.Id

--Q2
select Distinct R.FirstName+' '+ R.LastName FullName, R.Email,RP.Id, RP.Title
from Researcher R join ResearchProject RP
on R.Id=RP.LeaderId
join Funds F
on RP.Id=F.ProjectId

--Q3
select R.Id,R.FirstName+' '+ R.LastName FullName,P.Id,p.Title
from Researcher R cross join Publication P

--cross join display all possible results and large data may make the server fail[duplicates rows}

--Q4
select R1.FirstName+' '+ R1.LastName SupervisorName,R2.FirstName+' '+ R2.LastName SupervisedName, s.SupervisionStartDate,s.Role
from Researcher R1 join Supervises S
on R1.Id=S.SupervisorId
join Researcher R2
on R2.Id=s.SupervisedId

--Q5
select Distinct R.Id, R.FirstName + ' ' +R.LastName FUllName
from Researcher R join Publishes P
on R.Id=P.ResearcherId
Where R.Id not in(
select W.ResearcherId
from ResearchProject RP join WorksOn W
on W.ProjectId=RP.Id
where RP.Status='Active')

--Q6
select Top(5) with Ties *
from Publication P
order By P.CitationCount Desc

--Q7
Select *
from Researcher R
order By R.LastName
offset 10 rows
Fetch Next 10 rows only

--Q8
SELECT TOP 3 *
FROM Researcher
ORDER BY LastName

SELECT *
FROM Researcher
ORDER BY LastName
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY

--Yes both Retreive Same Values
--Offset &Fetch using in Pagination While Top not,Best than Top When We have Large Data
--And best When We need to Retreive Spicific Data ir Pages

--Q9
select R.Id,R.FirstName+' '+ R.LastName FullName, R.DateOfBirth,R.Building
,ROW_NUMBER() over (Partition By R.Building Order By R.DateOfBirth) ResesrcherIndex
from Researcher R 

--Q10
select P.Title,P.Type,p.CitationCount,
RANK() over (Partition By p.Type order By p.CitationCount desc) PublicationRank
from Publication P

--Q11
select R.Title ,R.Budget,R.Status,
DENSE_RANK() over (Partition By R.Status order By R.Budget desc) ResearchRank1,
RANK() over (Partition By R.Status order By R.Budget desc) ResearchRank2
from ResearchProject R
/*
RANK() gives same rank to same rows and then skips the next numbers (1, 2, 2, 4) leaving gaps
DENSE_RANK() gives same rank to same rows but continues consecutively (1, 2, 2, 3) with no gaps
*/

--Q12
select R.Id,R.FirstName+' '+ R.LastName FullName,COUNT(P.PublicationId) CountOfPublication
,NTILE(4) over (Order By Count(P.PublicationId) desc) GroupNumber
from Researcher R join Publishes P
on R.Id=P.ResearcherId
Group By R.Id,R.FirstName + ' ' + R.LastName

--Q13
--From->Where->GroupBy->Having->Select->OrderBy->Offset-fetch/Top
/*
from: Identifies the tables
where: Filters rows before grouping
GroupBy: Groups rows with the same values
Having: Filters groups after aggregation
select: Determines the columns will return
OrderBy: Sorts the result set
Offset-Fetch/Top: Limits the returned rows or skips a specified number of rows
*/

--Q14
/*
SELECT ResearcherId, COUNT(*) as ProjectCount
FROM WorksOn
WHERE ProjectCount > 2 
GROUP BY ResearcherId
*/
--We can not use Alias name in where because select implemented after where and can not use Aggregate Function with Where
--to solve this problem we use Having to filter groups 
SELECT ResearcherId, COUNT(*) as ProjectCount
FROM WorksOn
GROUP BY ResearcherId
Having COUNT(*)>2

--Q15
select R.FirstName +' '+ISNULL(R.MiddleName + ' ', '')+R.LastName FullName,LOWER(R.Email) Email,
DATEDIFF(YEAR, DateOfBirth, GETDATE()) Age
from Researcher R

--Q16
select R.Id,R.Title,R.StartDate,R.EndDate,
DATEDIFF(Day,R.StartDate,ISNULL(R.EndDate,GETDATE())) Duration,
MONTH(R.StartDate) Month,
YEAR(R.StartDate) Year
from ResearchProject R

--Q17
select *
from Researcher
where Email LIKE '%@university.edu'

--Q18
select R.Id,R.FirstName,ISNULL(R.MiddleName,'N/A') MiddleName,R.LastName,R.Email,R.DateOfBirth,ISNULL(R.RoomNumber ,'N/A')RoomNumber
from Researcher R

--Q19
select R.Id,R.Title,R.Budget,
CASE 
when R.Budget<50000 then 'Small'
when R.Budget BETWEEN 50000 and 150000 then 'Medium'
when R.Budget >150000 then 'Large'
END Category
from ResearchProject R

--Q20
select r.Id,R.FirstName+' '+R.LastName FullName,Sum(RP.Budget) TotalBudget
from Researcher R join ResearchProject RP
on R.Id=RP.LeaderId
Group By R.Id,R.FirstName + ' ' + R.LastName

--Q21
select R.Building ,COUNT(*) CountOFResearcher
from Researcher R
Group By R.Building
Having COUNT(*)>3

--Q22
select P.Type, AVG(P.CitationCount *1.0) AverageCitation ,SUM(P.CitationCount) TotalCitation,COUNT(*) CountOfPuplication
from Publication P
Group By P.Type
Having AVG(P.CitationCount)>50

--Q23
select W.ResearcherId ,COUNT(W.ProjectId) CountOfProjects ,SUM(W.HoursPerWeek) TotalHours
from WorksOn W
Group By W.ResearcherId
Having COUNT(W.ProjectId)>2 and SUM(W.HoursPerWeek)>60

--Q24
select *
from ResearchProject
where Budget>
     (select AVG(Budget*1.0)
      from ResearchProject)

--Q25*
select *
from Researcher R1
where
    (select COUNT(*)
     from Publishes P1
     where P1.ResearcherId = R1.Id)
    >
    (select AVG(1.0 * PublicationCount)
     from (
         select COUNT(P2.PublicationId) AS PublicationCount
         from Researcher R2
        left join Publishes P2
          on R2.Id = P2.ResearcherId
         where R2.Building = R1.Building
         Group By R2.Id)
     ResearcherBuilding)


--Q26
select *
from Researcher R
where Exists (
select 1
from Supervises S
where R.Id=S.SupervisorId)

--Q27
select RP.Id,RP.Title,(select COUNT(W.ResearcherId)
from WorksOn W
where w.ProjectId=RP.Id) CountOfResearchers
from ResearchProject RP

--Q28*
select MaX(R.Budget) SecondMaxBudget
from ResearchProject R
where R.Budget<
(select MaX(Budget) 
from ResearchProject)

--Q29*
select R.Id,R.FirstName,R.LastName
from Researcher R
where Exists (
select * from WorksOn w
where w.ResearcherId=R.Id)
And Not Exists(
select *
from Publishes p
where p.ResearcherId=R.Id)

--Q30
select R.Id,R.FirstName,R.LastName
from Researcher R
where Exists (
select *
from Supervises S
where S.SupervisorId=R.Id)
and Exists(
select * from ResearchProject RP
where R.Id=RP.LeaderId)

--Q31
Create Or Alter Function dbo.GetActiveDays (@ProjectId VarChar(10))
Returns int
As
Begin
Return(
select DATEDIFF(Day ,StartDate,ISNULL(EndDate,GETDATE()))
from ResearchProject
where Id=@ProjectId
)
End

select dbo.GetActiveDays('P001') ActiveDays

--Q32
Create Or Alter Function dbo.GetProjects(@ResearcherId VarChar(10))
Returns Table
As
Return 
(
select R.Title,W.Role,w.HoursPerWeek
from ResearchProject R join WorksOn w
on R.Id=w.ProjectId
Where W.ResearcherId=@ResearcherId
)
select * from dbo.GetProjects('R001')

--Q33
Create Or Alter Function dbo.GetResearcherInfo(@ResearcherId VarChar(10))
Returns @table Table
(

    TotalProjects int,
    TotalPublications int,
    TotalHoursPerWeek int,
    AvgCitations Float
)
As
Begin
insert into @table
Select
(Select COUNT(*)
from WorksOn
where ResearcherId=@ResearcherId),
(select COUNT(*)
from Publishes 
where ResearcherId=@ResearcherId),
(select ISNULL(SUM(HoursPerWeek),0)
from WorksOn 
where ResearcherId=@ResearcherId),
(Select AVG(p.CitationCount*1.0)
from Publication p join Publishes P1
on p.Id=P1.PublicationId
where P1.ResearcherId=@ResearcherId)
Return
End
select * from dbo.GetResearcherInfo('R001')
--MultiValued prefered Bacuase it lower Performance Than inline because resuls are stored in table variable
--multi is prefered with complex logic

--Q34
Create NonClustered Index IX_ResearchProjectIndex
on ResearchProject(Status,StartDate)

--Q35
/*
*clustered index -> defines the physical order of the rows of table
*non clustered index -> contains indexed key values and pointers to the actual rows
*You can add only one clustered index in one table but any count of no clustured
*existing non clustered indexes are not deleted and aql Server rebuilds this non clustered indexe
*/

--Q36
Create NonClustered Index IX_ResearcherIndex
on Researcher (Email)
include (FirstName, LastName)

--improve performance because sql Server can retrieve all required data directly from the index [Email]
--without accessing the original table

--Q37*
Create Or Alter View VW_ActiveProjectSummary
As
Select RP.Title,R.FirstName + ' ' + R.LastName LeaderName,
 COUNT(w.ResearcherId) NumberOfTeamMembers,SUM(w.HoursPerWeek) TotalHoursPerWeek,SUM(RP.Budget) TotalBudget
from Researcher R join ResearchProject RP
on R.Id=RP.LeaderId
left join WorksOn w
on w.ProjectId=RP.Id
Group By RP.Title,R.FirstName + ' ' + R.LastName

select * from VW_ActiveProjectSummary

--Q38
Create or Alter View dbo.VW_ResearcherPublicationStats
With SchemaBinding
As
select R.Id ID,R.FirstName + ' ' + R.LastName FullName ,COUNT_BIG(*) TotalOfPublication
from dbo.Researcher R join dbo.Publishes P
on R.Id=P.ResearcherId
Group By R.Id,R.FirstName + ' ' + R.LastName

Create Unique Clustered Index IX_ResearcherPublicationStats
on dbo.VW_ResearcherPublicationStats (ID)

select * from dbo.VW_ResearcherPublicationStats

--Q39
/*
necessary requirements for indexed view
   * With SchemaBinding
   * Two part table names (dbo.TableName)
   * COUNT_BIG(*) when using GROUP BY
   * Unique Clustered Index on the view
   * No outer joins, DISTINCT, TOP, or subqueries
*/

--Benefits-> Its results are physically stored and automatically maintained
--i will choose indexed view when executed query performs aggregation Functions or joins on large data 

--Q40*
Create Or Alter procedure AddResearcherToProject   @ResearcherId VarChar(10),
    @ProjectId VarChar(10),
    @JoinDate Date,
    @Role VarChar(50),
    @HoursPerWeek int
As
Begin
Begin Try
if not Exists (
select *
from Researcher 
where Id=@ResearcherId )
Return -1

if not Exists (
select *
from ResearchProject
where Id =@ProjectId )
Return -1
if Exists (
select *
from WorksOn w 
where w.ResearcherId=@ResearcherId and w.ProjectId=@ProjectId)
Return -1

insert into WorksOn (ResearcherId, ProjectId, JoinDate, Role, HoursPerWeek)
Values (@ResearcherId, @ProjectId, @JoinDate, @Role, @HoursPerWeek)

Return 0
End Try
Begin Catch
Return -1
End Catch
End

Declare @Result Int
Exec @Result = AddResearcherToProject 'R001', 'P001', '2022-01-01', 'Researcher', 40
Select @Result 

--Q41
Create Or Alter Procedure dbo.UpdateProjectStatus @ProjectId VarChar(10)
As
Begin
Begin Try
if not Exists(
select *
from ResearchProject
where Id=@ProjectId)
Throw 50001, 'Project does not exist', 1

if not Exists(
select *
from ResearchProject
where Id=@ProjectId and Status='Pending')
Throw 50001, 'Project is not Pending', 1

if not Exists(
select *
from WorksOn
where ProjectId=@ProjectId)
Throw 50001, 'No researcher assigned to this project', 1

if not Exists(
select *
from ProjectFundingAgency
where ProjectId=@ProjectId)
Throw 50001, 'Project has no funding source', 1

Update ResearchProject
set Status = 'Active'
where Id = @ProjectId
End Try
Begin Catch
Throw;
End Catch
End

Exec dbo.UpdateProjectStatus 'P002'

--Q42
Create Or Alter Procedure dbo.GetResearcherInformation @ResearcherId VarChar(10),
    @TotalProjects int Output,
    @TotalPublications int Output,
    @TotalWeeklyHours int Output
As
Begin
select @TotalProjects= COUNT(*)
from WorksOn
where ResearcherId=@ResearcherId

select @TotalPublications=COUNT(*)
from Publishes
where ResearcherId=@ResearcherId

select @TotalWeeklyHours =ISNULL(Sum(HoursPerWeek),0)
from WorksOn
where ResearcherId=@ResearcherId
End

Declare @P int,@Pu int,@H int
Exec dbo.GetResearcherInformation 'R002', @TotalProjects = @P Output,
    @TotalPublications = @Pu Output,
    @TotalWeeklyHours = @H Output

select @P TotalProjects,@Pu TotalPublications,@H TotalWeeklyHours

--Q43
Create Or Alter Trigger TRG_CheckCountOfProjects
On WorksOn
After Insert
As
if Exists(
select ResearcherId
from WorksOn
Group By ResearcherId
Having COUNT(*)>5
)
ROLLBACK TRANSACTION;
THROW 50001, 'Researcher can not work on more than 5 projects', 1

--Q44
Create Or Alter Trigger TRG_UpdateProjectStatus
on ResearchProject
After Update
As
Update ResearchProject
set Status = 'Completed'
from ResearchProject RP join inserted I
on RP.Id = I.Id
where I.EndDate < GETDATE()

--use After Update because you need to update After Check the EndDate

--Q45
Create Table GrantsAudit
(
    AuditId int Identity(1,1) Primary key,
    GrantId VarChar(10),
    OldAmount Decimal(18,2),
    NewAmount Decimal(18,2),
    ModifiedBy NVarChar(128),
    ModifiedDate DATETIME
)

Create Or Alter Trigger TRG_AuditGrants
On Grants
After Update
As
insert into GrantsAudit (GrantId, OldAmount, NewAmount, ModifiedBy, ModifiedDate)
Select D.Id,D.Amount,I.Amount,SYSTEM_USER,GETDATE()
from deleted D join inserted I
on D.Id = I.Id

--Q46
Begin Try
    Begin Transaction
    Insert Into ResearchProject (Id, Title, StartDate, Budget, Status, LeaderId)
    Values ('P900', 'My Project', GETDATE(), 100000, 'Pending', 'R001')

    Insert Into WorksOn (ResearcherId, ProjectId, JoinDate, Role, HoursPerWeek)
    Values ('R001', 'P900', GETDATE(), 'Leader', 50)
    
    Insert Into Funds (GrantId, ProjectId, AllocationAmount, AllocationDate)
    Values ('G001', 'P900', 50000, GETDATE())
    Commit Transaction
End Try
Begin Catch
    if @@TRANCOUNT > 0
        Rollback Transaction
    Print 'Transaction failed: ' + ERROR_MESSAGE()
End Catch

Select * From ResearchProject Where Id = 'P900'

--Q47
/*
ACID Properties:
* Atomicity:
All or nothing Every transaction succeeds completely, or none of its changes are applied
Example: Creating a project and assigning a researcher must both succeed

* Consistency:
Rules are always respected. Data moves from one valid state to another
Example: A researcher must exist before being assigned to a project

* Isolation:
Transactions do not disturb each other while running at the same time
Example: Two admins updating the same project budget must not interfere with each other

* Durability:
Committed data is never lost, even after a crash
Example: After committing a new project it remains saved even if the server crashes
*/

--Q48
/*
in my opinion queryB may perform better because it checks whether a matching record exists and can stop after finding the first match
while QueryA compares the researcherId with the list of IDs

The actual performance depends on:
*Indexes on ResearcherId and ProjectId
* Number of rows in both tables
* The execution plan chosen
*/

--Q49

/*
*Create an index on ResearchProject(Status, StartDate DESC) to improve filtering and sorting
*Create an index on Researcher(Id) to improve matching researchers
*Select only the required columns instead of using select * to reduce unnecessary data retrieval
*/

--Q50
/*
Option A: Write the query each time
* Pros: Always gets the latest data
* Cons: We have to write the same query every time which takes time

Option B: Create a View
* Pros: Easy to use and we can use it whenever we need
* Cons: It does not save the results so the query runs every time

Option C: Create a Stored Procedure
* Pros: Easy to reuse and can take parameters
* Cons: We need to execute it every time we want the results

Option D: Create an Indexed View
* Pros: Faster because it stores the results
* Cons: Needs more storage and updates can be slower

I choose Option C (Stored Procedure) for these reasons:
* Performance-> It can run faster especially with an index 
* Maintenance -> The query is written in one place so if we need to change anything we only change it once
* Flexibility-> We can use parameters

while indexed view is not the best choice because it does not support TOP and it can make insert/ update/ delete operations slower


*/
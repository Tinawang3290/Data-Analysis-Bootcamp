-- 1. Find the number of days over which this data is collected.

select (max(date_received)-min(date_received)) as num_of_days from public.complaints

-- 2. How many distinct issues and sub-issues are there?
select count(distinct(issue)) as num_of_dissue,count(distinct(subissue)) as num_of_dsubissue from public.complaints

-- Breakdown
select distinct(issue) from public.complaints
select distinct(subissue) from public.complaints

-- 3. For each issue, how many consumers complained about that issue?
select issue, count(complaint_id) as num_complaints from public.complaints
group by issue
order by issue

-- 4. For each issue, sub-issue combination, how many consumers complained about that issue, sub-issue?
select issue, subissue, count(complaint_id) from public.complaints
group by issue, subissue
order by issue

-- 5. Find the answer to the 3 and 4 after filtering the data where we have the consumer_complaint_narrative.

-- For question#3
select issue, count(consumer_complaint_narrative) as num_complaints from public.complaints
where consumer_complaint_narrative != 'None'
group by issue
order by issue
--  for question#4
with foo as (select issue, subissue, consumer_complaint_narrative from public.complaints
where consumer_complaint_narrative != 'None')
select issue,subissue,count(consumer_complaint_narrative) as num_complaints from foo
group by issue,subissue

-- 6. Repeat 4, but this time only include (issue, sub-issue) combinations which have more than 100 people complaining.
select issue, subissue, count(complaint_id) from public.complaints
group by issue, subissue
having count(complaint_id) >=100
order by issue

-- 7. Write a query that outputs the most common issue overall.
select issue, count(1) as num_issues from public.complaints
group by issue
order by num_issues desc 
limit 1

-- 8. Write a query that outputs the most common subissue within each issue overall.
with f as (select issue,subissue,count(subissue) as num_subissue,row_number() over(partition by issue order by count(subissue) DESC) as ranking from public.complaints
group by issue,subissue)
select * from f
where ranking = 1

-- 9. Write a query that outputs the most common subissue within each issue overall where we have the consumer_complaint_narrative.
with ff as (select issue,subissue, 
count(f.subissue) as num_subissue,row_number() over(partition by f.issue order by count(f.subissue) DESC) as ranking 
from (select * from public.complaints
where consumer_complaint_narrative != 'None')as f
group by f.issue,f.subissue
order by f.issue)
select issue, subissue, num_subissue from ff
where ranking = 1 
order by issue

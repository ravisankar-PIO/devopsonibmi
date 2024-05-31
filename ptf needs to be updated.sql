--
-- Subject: Stay Current
-- Author: Scott Forstie  
-- Date  : April, 2024
-- Features Used : This Gist uses SQL PL, systools.group_ptf_currency, sysibmadm.env_sys_info, SYSTOOLS.GENERATE_SPREADSHEET, SYSTOOLS.SEND_EMAIL
--
-- The age old problem is this... IBM recommends that IBM i clients stay up to date 
-- on software updates... but how does a client get current and stay current?
--
-- This confluence of technologies highlights one approach to consider.
-- #SQLcandoit
--
-- Note: 
-- One time setup to be able to send an email from the IBM i
call qsys2.qcmdexc('QSYS/ADDUSRSMTP USRPRF(' concat user concat ')');

-- Resources:
-- https://www.ibm.com/docs/en/i/7.5?topic=services-group-ptf-currency-view
-- https://www.ibm.com/docs/en/i/7.5?topic=services-send-email-scalar-function
-- https://www.ibm.com/docs/en/i/7.5?topic=services-generate-spreadsheet-scalar-function
--
stop;

--
-- Review the PTF Group currency for this IBM i
--
With iLevel(iVersion, iRelease) AS
(
select OS_VERSION, OS_RELEASE from sysibmadm.env_sys_info
)
  SELECT P.*
     FROM iLevel, systools.group_ptf_currency P
     WHERE ptf_group_release = 
           'R' CONCAT iVersion CONCAT iRelease concat '0'
     ORDER BY ptf_group_level_available -
        ptf_group_level_installed DESC;
stop;

--
-- Focus solely where updates are needed
--
With iLevel(iVersion, iRelease) AS
(
select OS_VERSION, OS_RELEASE from sysibmadm.env_sys_info
)
  SELECT P.*
     FROM iLevel, systools.group_ptf_currency P
     WHERE ptf_group_release = 
           'R' CONCAT iVersion CONCAT iRelease concat '0'
           and ptf_group_currency in ('UPDATE AVAILABLE')
     ORDER BY ptf_group_level_available -
        ptf_group_level_installed DESC;
stop;

--
-- Save the data to a table
--
select * from coolstuff.ptf_groups;

create or replace table coolstuff.PTF_GROUPS as
      (with iLevel (iVersion, iRelease) as (
            select OS_VERSION, OS_RELEASE
              from sysibmadm.env_sys_info
          )
          select P.*
            from iLevel, systools.group_ptf_currency P
            where ptf_group_release = 'R' concat iVersion concat iRelease concat '0' and
                  ptf_group_currency in ('UPDATE AVAILABLE')
            order by ptf_group_level_available - ptf_group_level_installed desc)
      with data
  on replace delete rows;
stop;

--
-- Proceduralize the logic
--
create or replace procedure Coolstuff.STAY_CURRENT (in to_email varchar(100))
    not deterministic
    modifies sql data
    program name stay_cur
    set option commit = *NONE, dynusrprf = *USER, usrprf = *USER
begin
  declare row_count integer;
  declare return_value integer;
--
-- Save the data to a table
--
  create or replace table coolstuff.PTF_GROUPS as
        (with iLevel (iVersion, iRelease) as (
              select OS_VERSION, OS_RELEASE
                from sysibmadm.env_sys_info
            )
            select P.*
              from iLevel, systools.group_ptf_currency P
              where ptf_group_release = 'R' concat iVersion concat iRelease concat '0' and
                    ptf_group_currency in ('UPDATE AVAILABLE')
              order by ptf_group_level_available - ptf_group_level_installed desc)
        with data
    on replace delete rows;
  -- Are there any PTF Groups that need to be updated?
  select count(*)
    into row_count
    from coolstuff.PTF_GROUPS;
  if (row_count > 0) then
    -- Take the PTF Group detail and generate a spreadsheet in the IFS
    values SYSTOOLS.GENERATE_SPREADSHEET(
        PATH_NAME => '/tmp/ptf_group_updates', LIBRARY_NAME => 'COOLSTUFF',
        FILE_NAME => 'PTF_GROUPS', SPREADSHEET_TYPE => 'xlsx', COLUMN_HEADINGS => 'COLUMN')
      into return_value;
    -- if the spreadsheet successfully generated, email it
    if (return_value = 1) then
      values SYSTOOLS.SEND_EMAIL(
          TO_EMAIL => to_email, SUBJECT => 'PTF Group Updates available for IBM i: ' concat
            (select host_name
                from sysibmadm.env_sys_info), BODY => 'There are ' concat row_count concat
            ' PTF Group updates available on ' concat current timestamp, ATTACHMENT => '/tmp/ptf_group_updates.xlsx')
        into return_value;
    end if;
  end if;
end; 
stop;

--
-- Test that the procedure works as intended
--
call Coolstuff.STAY_CURRENT('ravisankar.pandian@programmers.io');
stop;

--
-- Automate the report
--
cl: ADDJOBSCDE JOB(STAYCUR) CMD(RUNSQL SQL('call Coolstuff.STAY_CURRENT(''forstie@us.ibm.com'')') COMMIT(*NONE) NAMING(*SQL)) FRQ(*WEEKLY) SCDDATE(*NONE) SCDDAY(*ALL) SCDTIME(235500);
stop;


select *
  from table (
      qsys2.ifs_object_privileges('/')
    )
  where authorization_name = '*PUBLIC';

create or replace variable coolstuff.cldate char(7);

create or replace variable coolstuff.decdate dec(6,0);
set coolstuff.decdate = '190718';

values timestamp_format(varchar(coolstuff.decdate), 'YYMMDD'); 
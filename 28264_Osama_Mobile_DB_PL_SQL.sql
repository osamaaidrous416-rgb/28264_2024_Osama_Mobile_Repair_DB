-- ==========================================
-- MOBILE REPAIR SHOP DATABASE
-- PL/SQL Scripts
-- Student: Osama Aidrous
-- ==========================================

--------------------------------------------------------
--  DDL for Procedure ADD_CUSTOMER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "OSAMA_MOBILE_DB"."ADD_CUSTOMER" (
    p_customer_id NUMBER,
    p_full_name VARCHAR2,
    p_phone_number VARCHAR2,
    p_email VARCHAR2,
    p_address VARCHAR2
)
AS
BEGIN
    INSERT INTO Customers
    VALUES (
        p_customer_id,
        p_full_name,
        p_phone_number,
        p_email,
        p_address
    );

    COMMIT;
END;

/

--------------------------------------------------------
--  DDL for Procedure ADD_REPAIR_REQUEST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "OSAMA_MOBILE_DB"."ADD_REPAIR_REQUEST" (
    p_request_id NUMBER,
    p_device_id NUMBER,
    p_technician_id NUMBER,
    p_problem_description VARCHAR2,
    p_repair_cost NUMBER
)
AS
BEGIN
    INSERT INTO Repair_Requests (
        Request_ID,
        Device_ID,
        Technician_ID,
        Problem_Description,
        Request_Date,
        Repair_Status,
        Repair_Cost
    )
    VALUES (
        p_request_id,
        p_device_id,
        p_technician_id,
        p_problem_description,
        SYSDATE,
        'Pending',
        p_repair_cost
    );

    COMMIT;
END;

/
--------------------------------------------------------
--  DDL for Function GET_REPAIR_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "OSAMA_MOBILE_DB"."GET_REPAIR_COST" (
    p_request_id NUMBER
)
RETURN NUMBER
AS
    v_cost NUMBER;
BEGIN
    SELECT Repair_Cost
    INTO v_cost
    FROM Repair_Requests
    WHERE Request_ID = p_request_id;

    RETURN v_cost;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;

/
--------------------------------------------------------
--  DDL for Package REPAIR_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "OSAMA_MOBILE_DB"."REPAIR_PACKAGE" AS

    PROCEDURE Show_All_Repairs;

    FUNCTION Total_Repairs
    RETURN NUMBER;

END Repair_Package;

/
--------------------------------------------------------
--  DDL for Trigger AUDIT_REPAIR_TRIGGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "OSAMA_MOBILE_DB"."AUDIT_REPAIR_TRIGGER" 
AFTER INSERT OR UPDATE OR DELETE
ON Repair_Requests
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
    ELSIF DELETING THEN
        v_operation := 'DELETE';
    END IF;

    INSERT INTO Audit_Log (
        Audit_ID,
        Table_Name,
        Operation_Type,
        User_Name,
        Operation_Date
    )
    VALUES (
        Audit_Log_SEQ.NEXTVAL,
        'Repair_Requests',
        v_operation,
        USER,
        SYSDATE
    );
END;

/
ALTER TRIGGER "OSAMA_MOBILE_DB"."AUDIT_REPAIR_TRIGGER" ENABLE;


--------------------------------------------------------
--  DDL for Trigger WORK_DAY_RESTRICTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "OSAMA_MOBILE_DB"."WORK_DAY_RESTRICTION" 
BEFORE INSERT OR UPDATE OR DELETE
ON Repair_Requests
BEGIN
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')
       IN ('MON','TUE','WED','THU','FRI') THEN

        RAISE_APPLICATION_ERROR(
            -20002,
            'Changes are not allowed on working days.'
        );
    END IF;
END;

/
ALTER TRIGGER "OSAMA_MOBILE_DB"."WORK_DAY_RESTRICTION" ENABLE;

SET SERVEROUTPUT ON;

CREATE TABLE department (
  dept_id NUMBER(5) NOT NULL PRIMARY KEY,
  dept_name VARCHAR2(20) UNIQUE NOT NULL,
  dept_location VARCHAR2(2) NOT NULL
);

CREATE SEQUENCE dept_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;


-- Insert initial data
INSERT INTO department(dept_id, dept_name, dept_location)
VALUES(dept_id_seq.nextval, 'HR', 'NY');

INSERT INTO department(dept_id, dept_name, dept_location)
VALUES(dept_id_seq.nextval, 'IT', 'CA');

INSERT INTO department(dept_id, dept_name, dept_location)
VALUES(dept_id_seq.nextval, 'SALES', 'TX');

INSERT INTO department(dept_id, dept_name, dept_location)
VALUES(dept_id_seq.nextval, 'marketing', 'NJ');

INSERT INTO department(dept_id, dept_name, dept_location)
VALUES(dept_id_seq.nextval, 'FINANCE', 'MA');

INSERT INTO department(dept_id, dept_name, dept_location)
VALUES(dept_id_seq.nextval, 'LEGAL', 'NH');

select * from department;

CREATE OR REPLACE PROCEDURE MANAGE_DEPT(
    p_dept_name IN VARCHAR2,
    p_dept_location IN VARCHAR2
)
IS
    v_dept_name VARCHAR2(40);
    v_dept_location VARCHAR2(100);
    v_count NUMBER;
    --dept_name_null_exception EXCEPTION;
BEGIN
    -- Validate department name
    IF p_dept_name IS NULL OR LENGTH(p_dept_name) = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Department name cannot be null or empty.'); --ERROR
    ELSIF REGEXP_LIKE(p_dept_name, '^[0-9]+$') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Department name cannot be a number.');      --ERROR
    END IF;

    -- Convert department name to camel case
    Select Replace(Replace(Initcap(p_dept_name),' ',''),'-','') INTO v_dept_name
    from dual;

    -- Validate department location
    IF p_dept_location NOT IN ('MA', 'TX', 'IL', 'CA', 'NY', 'NJ', 'NH', 'RH') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Department location is not valid.');        --ERROR
    END IF;
    v_dept_location := p_dept_location;
    
    -- Check if department name length is more than 20 chars
    IF LENGTH(p_dept_name) > 20 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Department name cannot be more than 20 characters.');    --ERROR
    END IF;
    
    -- Check if department name already exists
    SELECT COUNT(*) INTO v_count FROM DEPARTMENT WHERE dept_name = v_dept_name;
    IF v_count = 0 THEN
        -- Insert new department
        INSERT INTO DEPARTMENT(dept_id, dept_name, dept_location)
        VALUES(dept_id_seq.NEXTVAL, v_dept_name, p_dept_location);
        DBMS_OUTPUT.PUT_LINE('Department inserted successfully.');
    ELSE
        -- Update department location
        UPDATE DEPARTMENT SET dept_name = v_dept_name, dept_location = p_dept_location WHERE dept_name = p_dept_name;
        DBMS_OUTPUT.PUT_LINE('Department updated successfully.');
    END IF;
    COMMIT;
      
END;

/


--TEST CASE TO INSERT A DEPARTMENT WITH A NULL NAME
BEGIN
    MANAGE_DEPT(NULL, 'NY');  --ERROR
END;
/
--TEST CASE TO INSERT A DEPARTMENT WITH EMPTY NAME (ZERO LENGTH)
BEGIN
    MANAGE_DEPT('', 'NY');  --ERROR
END;
/
--TEST CASE TO INERT A DEPARTMENT NAME WITH A NUMBER
BEGIN
    MANAGE_DEPT(123, 'NY');  --ERROR
END;
/
-- TEST CASE TO INSERT A DEPARTMENT WITH INVALID LOCATION
BEGIN
    MANAGE_DEPT('Marketing', 'FL');
END;
/
--TEST CASE TO INSERT A DEPARTMENT NAME WITH MORE THAN 20 CHARACTERS
BEGIN
    MANAGE_DEPT('abcdefghijklmnopqrstuvwxyz', 'NY');  --ERROR
END;
/
-- TEST CASE TO INSERT A DEPARTMENT IF NAME DOESN'T EXIST
BEGIN
    MANAGE_DEPT('SAP', 'CA');
END;
/
--TEST CASE TO UPDATE A DEPARTMENT LOCATION IF NAME EXISTS
BEGIN
    MANAGE_DEPT('SAP', 'NY');
END;
/
--TEST CASE TO CONVERT DEPARTMENT NAME TO CAMELCASE
BEGIN
    MANAGE_DEPT('sales', 'NY');
    -- Test with a department name with spaces
    MANAGE_DEPT('marketing and sales', 'CA');
    -- Test with a department name with hyphens
    MANAGE_DEPT('product-development', 'TX');
    -- Test with a department name in uppercase
    MANAGE_DEPT('ENGINEERING', 'CA');
    -- Test with a department name with special characters
    MANAGE_DEPT('IT#ops', 'MA');    
END;
/
Select * from Department;

DROP SEQUENCE dept_id_seq;
DROP TABLE DEPARTMENT;